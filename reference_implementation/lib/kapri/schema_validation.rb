require "json"
require "pathname"

begin
  require "json_schemer"
rescue LoadError
  raise LoadError, "json_schemer fehlt. Im Repository bitte einmal `bundle install` ausführen."
end

module Kapri
  # Validates KAPRI JSON documents against the normative Draft 2020-12
  # schemas shipped with this repository. Semantic and cryptographic checks
  # remain the responsibility of the T3/T4 validators.
  module SchemaValidation
    SCHEMA_DIR = File.expand_path("../../../schemas", __dir__)
    SCHEMA_FILES = {
      manifest: "kap_manifest.schema.json",
      packing_list: "kap_packing_list.schema.json",
      composition: "kap_composition.schema.json",
      kdm: "kap_kdm.schema.json"
    }.freeze

    module_function

    def validate(document, schema_name)
      schemer(schema_name).validate(document).map { |error| format_error(error) }.to_a
    end

    def schemer(schema_name)
      @schemers ||= {}
      @schemers[schema_name] ||= begin
        filename = SCHEMA_FILES.fetch(schema_name)
        schema = JSON.parse(File.read(File.join(SCHEMA_DIR, filename)))
        JSONSchemer.schema(schema, format: true)
      end
    end

    def format_error(error)
      pointer = error.fetch("data_pointer", "")
      location = pointer.empty? ? "$" : "$#{pointer}"
      "#{location}: #{error.fetch('error')}"
    end
    private_class_method :format_error
  end
end
