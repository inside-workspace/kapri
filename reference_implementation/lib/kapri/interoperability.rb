module Kapri
  # T5 - Interoperability reference implementation (scaffold only).
  #
  # specification/17: T5 SS1.1 defines Interoperability as verification
  # "that independently developed Producers and Consumers consistently
  # generate, exchange and validate Knowledge Asset Packages" - by
  # definition this requires at least two independently developed
  # implementations. Only one implementation (this one) currently exists,
  # so T5.1-T5.7 cannot yet be meaningfully implemented: there is nothing
  # independent to exchange with, compare against, or determine
  # interoperability with.
  #
  # This module therefore only defines the seven T5.x method signatures
  # implied by SS2.3's workflow (specification/17: T5 SS3, Conformance
  # Tests table), each raising NotImplementedError with a pointer back to
  # this comment. Fill them in once a second, independently developed
  # implementation (Producer and/or Consumer) exists to test against.
  module Interoperability
    NOT_YET_POSSIBLE =
      "T5 setzt mindestens zwei unabhängig voneinander entwickelte Implementierungen voraus " \
      "(specification/17: T5 SS1.1). Bisher existiert nur die KAPRI-Referenzimplementierung selbst - " \
      "dieser Schritt ist daher noch nicht sinnvoll implementierbar.".freeze

    # T5.1 - Process KAPRI Reference Package
    #
    # Intended to have a participating implementation process the KAPRI
    # Reference Package and perform all applicable Technical Validation
    # defined by S0 and T3 (this repo's own T3 is exactly this, for this
    # implementation).
    def self.process_kapri_reference_package(package_dir:)
      raise NotImplementedError, NOT_YET_POSSIBLE
    end

    # T5.2 - Generate Implementation Package
    #
    # Intended to have each participating Producer implementation generate
    # a Package according to T2 - Package Generation (in practice: one
    # participating implementation's Package Generation pipeline, e.g.
    # this repo's T2).
    def self.generate_implementation_package(output_dir:, pki_dir:)
      raise NotImplementedError, NOT_YET_POSSIBLE
    end

    # T5.3 - Exchange Package
    #
    # Intended to transfer the Package produced by T5.2 to an
    # independently developed Consumer implementation, unmodified.
    def self.exchange_package(package_dir:, destination:)
      raise NotImplementedError, NOT_YET_POSSIBLE
    end

    # T5.4 - Validate Exchanged Package
    #
    # Intended to have the receiving (independent) implementation run its
    # own Package Validation (its equivalent of this repo's T3) over the
    # exchanged Package.
    def self.validate_exchanged_package(package_dir:)
      raise NotImplementedError, NOT_YET_POSSIBLE
    end

    # T5.5 - Validate Secure Delivery
    #
    # Intended to have the receiving implementation run its own Secure
    # Delivery process (its equivalent of this repo's T4) over the
    # exchanged Package, where it contains encrypted Package Files.
    def self.validate_secure_delivery(package_dir:)
      raise NotImplementedError, NOT_YET_POSSIBLE
    end

    # T5.6 - Compare Technical Validation Results
    #
    # Intended to compare the validation results produced by the
    # generating implementation against those produced by the receiving
    # implementation for the same Package.
    def self.compare_technical_validation_results(reference_report:, exchanged_report:)
      raise NotImplementedError, NOT_YET_POSSIBLE
    end

    # T5.7 - Determine Interoperability
    #
    # Intended to determine, from T5.6's comparison, whether the two
    # implementations are interoperable.
    def self.determine_interoperability(comparison_result:)
      raise NotImplementedError, NOT_YET_POSSIBLE
    end
  end
end
