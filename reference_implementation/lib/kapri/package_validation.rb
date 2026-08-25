require "json"
require "openssl"
require_relative "hasher"
require_relative "signer"
require_relative "canonicalization"
require_relative "document_validation"
require_relative "schema_validation"
require_relative "workspace"

module Kapri
  # T3 - Package Validation reference implementation.
  #
  # Implements the nine structural/cryptographic checks defined by
  # specification/15: T3.md SS2.2 plus the aggregating report (T3.10). Each
  # public validate_* method corresponds to one T3.x conformance test and
  # returns a CategoryResult - it never raises on a malformed or malicious
  # Package, since producing exactly that verdict ("INVALID", with
  # reasons) is the point of a validator. Only a missing output_dir itself,
  # or similar environmental failure, is allowed to raise.
  #
  # Deliberate scope decisions not settled by the abstract specifications
  # (documented inline where they matter):
  #
  # - Certificate resolution: every certificate_chain entry embeds its own
  #   certificate (SC1 SS4.13 Certificate Reference), so T3.3/T3.4 validate
  #   entirely from the Package itself - no external PKI directory lookup
  #   is required or performed. Trust in the root certificate remains a
  #   Consumer Decision (S0 SS7.2), intentionally out of scope here.
  # - S3 SS6 requires Composition Item hierarchies to be acyclic and every
  #   Composition Item to be reachable from a top-level item. Both are
  #   structurally guaranteed by parsing JSON into the "items" tree plus
  #   this module's item_id uniqueness and relation-reference checks
  #   (JSON parsing cannot produce cycles or unreachable nodes reachable
  #   only via back-references) - no separate check is implemented for
  #   either rule.
  # - "Every referenced file_id SHALL identify an existing file defined by
  #   the Packing List" is listed under S3 SS6 (Composition) but is
  #   validated here under T3.9 (Cross References) together with the other
  #   inter-document consistency checks, since it is a cross-document
  #   reference by nature. validate_composition (T3.6) therefore covers
  #   only Composition-internal structural rules.
  module PackageValidation
    include DocumentValidation

    CategoryResult = Struct.new(:name, :valid, :errors, keyword_init: true)
    Report = Struct.new(:categories, :valid, keyword_init: true)

    # T3.1 - Open Package
    def self.validate_package_structure(output_dir:)
      name = "Package Structure"
      errors = []
      package_dir = Workspace.package_dir(output_dir)

      manifest_path = File.join(package_dir, "manifest.json")
      if !File.exist?(manifest_path)
        errors << "manifest.json fehlt in #{output_dir}"
      else
        _doc, load_errors = DocumentValidation.load_json(manifest_path)
        errors.concat(load_errors)
      end

      errors << "packing-list.json fehlt in #{package_dir}" unless File.exist?(File.join(package_dir, "packing-list.json"))
      errors << "keine Composition unter compositions/ gefunden" if Dir.glob(File.join(package_dir, "compositions", "*.json")).empty?

      CategoryResult.new(name: name, valid: errors.empty?, errors: errors)
    end

    # T3.2 - Validate Package Manifest
    def self.validate_manifest(output_dir:)
      name = "Package Manifest"
      manifest, errors = DocumentValidation.load_json(File.join(Workspace.package_dir(output_dir), "manifest.json"))
      return CategoryResult.new(name: name, valid: false, errors: errors) if manifest.nil?

      errors = SchemaValidation.validate(manifest, :manifest)
      return CategoryResult.new(name: name, valid: false, errors: errors) unless manifest.is_a?(Hash)
      errors.concat(DocumentValidation.validate_signature_structure(manifest["signature"]))
      errors << "published_at muss ein ISO-8601-Zeitstempel in UTC sein" unless DocumentValidation.utc_timestamp?(manifest["published_at"])
      validity = manifest["validity"]
      if validity.is_a?(Hash)
        errors << "validity.valid_from muss ein ISO-8601-Zeitstempel in UTC sein" unless DocumentValidation.utc_timestamp?(validity["valid_from"])
        if validity.key?("valid_until")
          errors << "validity.valid_until muss ein ISO-8601-Zeitstempel in UTC sein" unless DocumentValidation.utc_timestamp?(validity["valid_until"])
          if DocumentValidation.timestamp?(validity["valid_from"]) && DocumentValidation.timestamp?(validity["valid_until"]) && Time.iso8601(validity["valid_until"]) < Time.iso8601(validity["valid_from"])
            errors << "validity.valid_until darf nicht vor validity.valid_from liegen"
          end
        end
      end
      errors.concat(validate_document_reference_crypto(manifest["packing_list"], "packing_list"))
      (manifest["compositions"].is_a?(Array) ? manifest["compositions"] : []).each_with_index do |reference, index|
        errors.concat(validate_document_reference_crypto(reference, "compositions[#{index}]"))
      end

      CategoryResult.new(name: name, valid: errors.empty?, errors: errors)
    end

    # T3.3 - Validate Digital Signature
    #
    # Uses the leaf certificate embedded in signature.certificate_chain[0]
    # (SC1 SS4.13) directly - no external PKI lookup required, the Package
    # is self-contained.
    def self.validate_signature(output_dir:)
      name = "Digital Signature"
      manifest, errors = DocumentValidation.load_json(File.join(Workspace.package_dir(output_dir), "manifest.json"))
      return CategoryResult.new(name: name, valid: false, errors: errors) if manifest.nil?
      return CategoryResult.new(name: name, valid: false, errors: ["manifest.json muss ein Objekt sein"]) unless manifest.is_a?(Hash)

      signature = manifest["signature"]
      return CategoryResult.new(name: name, valid: false, errors: ["signature fehlt"]) unless signature.is_a?(Hash)
      return CategoryResult.new(name: name, valid: false, errors: ["signature.algorithm muss 'PS256' sein"]) unless signature["algorithm"] == Signer::ALGORITHM
      unless DocumentValidation.base64url?(signature["signature_value"], decoded_length: 384)
        return CategoryResult.new(name: name, valid: false, errors: ["signature.signature_value ist kein gültiger PS256-Wert"])
      end

      certs, chain_errors = DocumentValidation.parse_certificate_chain(signature["certificate_chain"])
      return CategoryResult.new(name: name, valid: false, errors: chain_errors) if certs.nil?

      valid = Signer.verify_document(manifest, certs.first.public_key)
      CategoryResult.new(name: name, valid: valid, errors: valid ? [] : ["digitale Signatur ist ungültig"])
    end

    # T3.4 - Validate Certificate Chain
    #
    # Validates the certificate_chain embedded in the Manifest's own
    # signature (SC1 SS4.13: leaf-to-root, each certificate issued by the
    # next, root self-issued), that every certificate was valid at
    # published_at, and that the leaf Producer Certificate's Subject
    # Alternative Name corresponds to responsible_organization.organization_id
    # (S1 SS3.2.9/SS6) - not the local reference PKI (that is T1.5's
    # concern, which tests PKI *generation* rather than a *received*
    # Package). Trust in the root remains a Consumer Decision (S0 SS7.2),
    # out of scope here.
    def self.validate_certificate_chain(output_dir:)
      name = "Certificate Chain"
      manifest, errors = DocumentValidation.load_json(File.join(Workspace.package_dir(output_dir), "manifest.json"))
      return CategoryResult.new(name: name, valid: false, errors: errors) if manifest.nil?
      return CategoryResult.new(name: name, valid: false, errors: ["manifest.json muss ein Objekt sein"]) unless manifest.is_a?(Hash)

      signature = manifest["signature"]
      return CategoryResult.new(name: name, valid: false, errors: ["signature fehlt"]) unless signature.is_a?(Hash)

      certs, chain_errors = DocumentValidation.parse_certificate_chain(signature["certificate_chain"])
      return CategoryResult.new(name: name, valid: false, errors: chain_errors) if certs.nil?

      errors = DocumentValidation.validate_chain_integrity(certs)
      errors.concat(DocumentValidation.validate_reference_chain_profile(certs, leaf_role: :producer))

      # T3 SS2.3: Certificate Chain validation SHALL include verification
      # that every certificate in the chain was valid at the published_at
      # timestamp declared by the Package Manifest.
      published_at = manifest["published_at"]
      if DocumentValidation.timestamp?(published_at)
        errors.concat(DocumentValidation.validate_chain_validity_period(certs, at: Time.iso8601(published_at)))
      else
        errors << "published_at fehlt oder ist kein gültiger Timestamp - Gültigkeitsprüfung der Zertifikatskette nicht möglich"
      end

      # S1 SS3.2.9/SS6: responsible_organization.organization_id SHALL
      # exactly match a SAN uniformResourceIdentifier of the leaf Producer
      # Certificate (certificate_chain is leaf-first, SC1 SS4.13).
      organization_id = DocumentValidation.value_at(manifest, "responsible_organization", "organization_id")
      producer_sans = DocumentValidation.subject_alternative_name_uris(certs.first)
      unless producer_sans.include?(organization_id)
        errors << "responsible_organization.organization_id (#{organization_id.inspect}) entspricht keinem Subject Alternative Name des Producer-Zertifikats (#{producer_sans.inspect})"
      end

      CategoryResult.new(name: name, valid: errors.empty?, errors: errors)
    end

    # T3.5 - Validate Packing List
    def self.validate_packing_list(output_dir:)
      name = "Packing List"
      packing_list, errors = DocumentValidation.load_json(File.join(Workspace.package_dir(output_dir), "packing-list.json"))
      return CategoryResult.new(name: name, valid: false, errors: errors) if packing_list.nil?

      errors = SchemaValidation.validate(packing_list, :packing_list)
      return CategoryResult.new(name: name, valid: false, errors: errors) unless packing_list.is_a?(Hash)

      files = packing_list["files"]
      if files.is_a?(Array) && !files.empty?
        seen_file_ids = Hash.new(0)
        seen_paths = Hash.new(0)

        files.each_with_index do |f, i|
          unless f.is_a?(Hash)
            errors << "files[#{i}] ist kein Objekt"
            next
          end

          if DocumentValidation.present_string?(f["path"])
            errors << "files[#{i}].path ist kein sicherer relativer Pfad (absolut oder enthält '..')" unless DocumentValidation.safe_relative_path?(f["path"])
          else
            errors << "files[#{i}].path fehlt"
          end
          errors << "files[#{i}].hash_algorithm muss 'SHA-256' sein" unless f["hash_algorithm"] == Hasher::ALGORITHM
          errors << "files[#{i}].hash ist kein SHA-256-Wert in Base64url ohne Padding" unless DocumentValidation.sha256_value?(f["hash"])

          seen_file_ids[f["file_id"]] += 1 if f["file_id"]
          seen_paths[f["path"]] += 1 if f["path"]
        end

        seen_file_ids.each { |id, count| errors << "file_id #{id} ist nicht eindeutig (#{count}x)" if count > 1 }
        seen_paths.each { |path, count| errors << "path #{path} ist nicht eindeutig (#{count}x)" if count > 1 }
      else
        errors << "files fehlt oder ist leer"
      end

      CategoryResult.new(name: name, valid: errors.empty?, errors: errors)
    end

    # T3.6 - Validate Composition (structural rules only - see module
    # comment for the file_id/Packing List cross-check, handled by T3.9).
    def self.validate_composition(output_dir:)
      name = "Composition"
      paths = Dir.glob(File.join(Workspace.package_dir(output_dir), "compositions", "*.json")).sort
      return CategoryResult.new(name: name, valid: false, errors: ["keine Composition unter compositions/ gefunden"]) if paths.empty?

      errors = []
      paths.each do |path|
        doc, load_errors = DocumentValidation.load_json(path)
        if doc.nil?
          errors.concat(load_errors)
          next
        end
        errors.concat(validate_single_composition(doc, File.basename(path)))
      end

      CategoryResult.new(name: name, valid: errors.empty?, errors: errors)
    end

    PACKAGE_DOCUMENT_BASENAMES = %w[manifest.json packing-list.json].freeze

    # T3.7 - Validate Package Files
    def self.validate_package_files(output_dir:)
      name = "Package Files"
      package_dir = Workspace.package_dir(output_dir)
      packing_list, errors = DocumentValidation.load_json(File.join(package_dir, "packing-list.json"))
      return CategoryResult.new(name: name, valid: false, errors: errors) if packing_list.nil?
      return CategoryResult.new(name: name, valid: false, errors: ["packing-list.json muss ein Objekt sein"]) unless packing_list.is_a?(Hash)

      errors = []
      files = packing_list["files"]
      listed_paths = []
      if files.is_a?(Array)
        files.each_with_index do |f, i|
          next unless f.is_a?(Hash)
          path = f["path"]
          if path.nil?
            errors << "files[#{i}] hat keinen path"
            next
          end
          listed_paths << path

          full_path = DocumentValidation.resolve_within(package_dir, path)
          if full_path.nil?
            errors << "files[#{i}].path ist kein sicherer relativer Pfad (absolut, enthält '..', oder verlässt das Package-Verzeichnis)"
          elsif !File.exist?(full_path)
            errors << "referenzierte Datei fehlt: #{path}"
          end
        end
      else
        errors << "packing-list.json enthält keine files-Liste"
      end

      # S2 SS3.2.4/SS6: every Package File contained in the Package SHALL
      # be represented by exactly one File Entry - the reverse direction of
      # the check above (every listed file exists) is that every physically
      # present file is listed.
      errors.concat(unlisted_package_files(package_dir, listed_paths))

      CategoryResult.new(name: name, valid: errors.empty?, errors: errors)
    end

    def self.unlisted_package_files(output_dir, listed_paths)
      base = File.expand_path(output_dir)
      errors = []

      Dir.glob(File.join(base, "**", "*")).each do |full_path|
        next unless File.file?(full_path)

        relative = full_path.delete_prefix("#{base}/")
        next if relative.start_with?("compositions/")
        next if !relative.include?("/") && PACKAGE_DOCUMENT_BASENAMES.include?(relative)

        errors << "Datei #{relative} ist im Package vorhanden, aber nicht in der Packing List gelistet" unless listed_paths.include?(relative)
      end

      errors
    end
    private_class_method :unlisted_package_files

    # T3.8 - Validate File Hashes
    def self.validate_file_hashes(output_dir:)
      name = "File Hashes"
      package_dir = Workspace.package_dir(output_dir)
      packing_list, errors = DocumentValidation.load_json(File.join(package_dir, "packing-list.json"))
      return CategoryResult.new(name: name, valid: false, errors: errors) if packing_list.nil?
      return CategoryResult.new(name: name, valid: false, errors: ["packing-list.json muss ein Objekt sein"]) unless packing_list.is_a?(Hash)

      errors = []
      files = packing_list["files"].is_a?(Array) ? packing_list["files"] : []
      files.each do |f|
        next unless f.is_a?(Hash)
        path = f["path"]
        next if path.nil?

        full_path = DocumentValidation.resolve_within(package_dir, path)
        next if full_path.nil? # bereits von T3.5/T3.7 gemeldet
        next unless File.exist?(full_path) # bereits von T3.7 gemeldet

        bytes = File.binread(full_path)
        if f["hash_algorithm"] != Hasher::ALGORITHM
          errors << "#{path}: nicht unterstützter Hash-Algorithmus #{f['hash_algorithm'].inspect}"
        elsif Hasher.sha256(bytes) != f["hash"]
          errors << "#{path}: Hash stimmt nicht (erwartet #{f['hash']}, berechnet #{Hasher.sha256(bytes)})"
        end
        if f["size"].is_a?(Integer) && f["size"] != bytes.bytesize
          errors << "#{path}: Größe stimmt nicht (erwartet #{f['size']}, tatsächlich #{bytes.bytesize})"
        end
      end

      CategoryResult.new(name: name, valid: errors.empty?, errors: errors)
    end

    # T3.9 - Validate Cross References
    def self.validate_cross_references(output_dir:)
      name = "Cross References"
      package_dir = Workspace.package_dir(output_dir)
      manifest, m_errors = DocumentValidation.load_json(File.join(package_dir, "manifest.json"))
      packing_list, pl_errors = DocumentValidation.load_json(File.join(package_dir, "packing-list.json"))
      return CategoryResult.new(name: name, valid: false, errors: m_errors + pl_errors) if manifest.nil? || packing_list.nil?
      unless manifest.is_a?(Hash) && packing_list.is_a?(Hash)
        return CategoryResult.new(name: name, valid: false, errors: ["manifest.json und packing-list.json müssen Objekte sein"])
      end

      errors = []

      # SC0 SS3.8: the referenced hash is over the RFC 8785 (JCS) canonical
      # form of the *parsed* document, not over whatever bytes happen to be
      # on disk (documents are stored pretty-printed for readability).
      expected_pl_hash = DocumentValidation.value_at(manifest, "packing_list", "hash")
      actual_pl_hash = document_hash(packing_list)
      errors << "manifest.packing_list.hash stimmt nicht mit packing-list.json überein" if expected_pl_hash && expected_pl_hash != actual_pl_hash

      packing_files = packing_list["files"].is_a?(Array) ? packing_list["files"] : []
      file_ids = packing_files.filter_map { |f| f["file_id"] if f.is_a?(Hash) }
      composition_paths = Dir.glob(File.join(package_dir, "compositions", "*.json"))

      manifest_compositions = manifest["compositions"].is_a?(Array) ? manifest["compositions"] : []
      manifest_compositions.each do |dr|
        next unless dr.is_a?(Hash)
        doc_id = dr["document_id"]

        path = composition_paths.find do |p|
          doc, = DocumentValidation.load_json(p)
          doc.is_a?(Hash) && doc["composition_id"] == doc_id
        end

        if path.nil?
          errors << "manifest referenziert Composition #{doc_id}, die nicht unter compositions/ existiert"
          next
        end

        composition, = DocumentValidation.load_json(path)
        actual_hash = document_hash(composition)
        errors << "manifest.compositions[].hash für #{doc_id} stimmt nicht mit der Datei überein" if dr["hash"] && dr["hash"] != actual_hash

        composition_items = composition.is_a?(Hash) && composition["items"].is_a?(Array) ? composition["items"] : []
        referenced_file_ids(composition_items).each do |fid|
          errors << "Composition #{doc_id} referenziert file_id #{fid}, der nicht in der Packing List existiert" unless file_ids.include?(fid)
        end
      end

      CategoryResult.new(name: name, valid: errors.empty?, errors: errors)
    end

    # T3.10 - Generate Validation Report
    #
    # Runs all nine checks unconditionally (not short-circuiting on the
    # first failure) so the report always covers every category, matching
    # the per-category breakdown requested for T3.10 instead of a single
    # VALID/INVALID verdict.
    def self.generate_report(output_dir:)
      categories = [
        validate_package_structure(output_dir: output_dir),
        validate_manifest(output_dir: output_dir),
        validate_signature(output_dir: output_dir),
        validate_certificate_chain(output_dir: output_dir),
        validate_packing_list(output_dir: output_dir),
        validate_composition(output_dir: output_dir),
        validate_package_files(output_dir: output_dir),
        validate_file_hashes(output_dir: output_dir),
        validate_cross_references(output_dir: output_dir)
      ]

      report = Report.new(categories: categories, valid: categories.all?(&:valid))
      write_report(output_dir, report)
      report
    end

    def self.validate_single_composition(composition, label)
      errors = SchemaValidation.validate(composition, :composition).map { |error| "#{label}: #{error}" }
      return errors unless composition.is_a?(Hash)

      items = composition["items"]
      unless items.is_a?(Array) && !items.empty?
        errors << "#{label}: items fehlt oder ist leer"
        return errors
      end

      item_ids = Hash.new(0)
      content_ids = Hash.new(0)
      collect_item_ids(items, item_ids, content_ids, errors, label)
      item_ids.each { |id, count| errors << "#{label}: item_id #{id} ist nicht eindeutig (#{count}x)" if count > 1 }
      content_ids.each { |id, count| errors << "#{label}: content_id #{id} ist nicht eindeutig (#{count}x)" if count > 1 }

      relation_ids = Hash.new(0)
      relations = composition["relations"].is_a?(Array) ? composition["relations"] : []
      relations.each_with_index do |rel, i|
        unless rel.is_a?(Hash)
          errors << "#{label}: relations[#{i}] ist kein Objekt"
          next
        end

        errors << "#{label}: relations[#{i}].relation_id fehlt oder ist keine gültige URI" unless DocumentValidation.uri?(rel["relation_id"])
        relation_ids[rel["relation_id"]] += 1 if rel["relation_id"]
        errors << "#{label}: relations[#{i}].source_item_id referenziert kein existierendes Composition Item" unless item_ids.key?(rel["source_item_id"])
        errors << "#{label}: relations[#{i}].target_item_id referenziert kein existierendes Composition Item" unless item_ids.key?(rel["target_item_id"])
        errors << "#{label}: relations[#{i}].source_item_id darf nicht gleich target_item_id sein" if rel["source_item_id"] && rel["source_item_id"] == rel["target_item_id"]
        errors << "#{label}: relations[#{i}].relation_type fehlt" unless DocumentValidation.present_string?(rel["relation_type"])
      end
      relation_ids.each { |id, count| errors << "#{label}: relation_id #{id} ist nicht eindeutig (#{count}x)" if count > 1 }

      errors
    end
    private_class_method :validate_single_composition

    def self.collect_item_ids(items, item_ids, content_ids, errors, label)
      items.each do |item|
        unless item.is_a?(Hash)
          errors << "#{label}: ein Composition Item ist kein Objekt"
          next
        end
        errors << "#{label}: item_id fehlt oder ist keine gültige URI" unless DocumentValidation.uri?(item["item_id"])
        item_ids[item["item_id"]] += 1 if item["item_id"]
        content_ids[item["content_id"]] += 1 if item["content_id"]
        collect_item_ids(item["items"], item_ids, content_ids, errors, label) if item["items"].is_a?(Array)
      end
    end
    private_class_method :collect_item_ids

    def self.referenced_file_ids(items)
      items.flat_map do |item|
        next [] unless item.is_a?(Hash)
        ids = item["file_ids"].is_a?(Array) ? item["file_ids"] : []
        ids + referenced_file_ids(item["items"].is_a?(Array) ? item["items"] : [])
      end
    end
    private_class_method :referenced_file_ids

    # SC0 SS3.8: same computation as PackageGeneration.document_hash -
    # canonical (RFC 8785/JCS) form of the parsed document, independent of
    # on-disk formatting.
    def self.document_hash(hash)
      Hasher.sha256(Canonicalization.serialize(hash))
    end
    private_class_method :document_hash

    def self.write_report(output_dir, report)
      data = {
        "categories" => report.categories.map { |c| { "name" => c.name, "valid" => c.valid, "errors" => c.errors } },
        "overall_result" => report.valid ? "VALID" : "INVALID"
      }
      File.write(Workspace.report_path(output_dir), JSON.pretty_generate(data))
    end

    def self.validate_document_reference_crypto(reference, field)
      return [] unless reference.is_a?(Hash)

      errors = []
      errors << "#{field}.hash_algorithm muss 'SHA-256' sein" unless reference["hash_algorithm"] == Hasher::ALGORITHM
      errors << "#{field}.hash ist kein SHA-256-Wert in Base64url ohne Padding" unless DocumentValidation.sha256_value?(reference["hash"])
      errors
    end
    private_class_method :validate_document_reference_crypto
    private_class_method :write_report
  end
end
