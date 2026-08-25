module Kapri
  # Directory contract for implementation-independent conformance workspaces.
  module ConformancePaths
    PACKAGE_NAME_PATTERN = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/
    PROJECT_ROOT = File.expand_path("../../..", __dir__)
    CONFORMANCE_ROOT = File.join(PROJECT_ROOT, "conformance_test")

    module_function

    def validate_package_name!(package_name)
      unless package_name&.match?(PACKAGE_NAME_PATTERN)
        raise ArgumentError, "package_name must contain only lowercase letters, digits and hyphens: #{package_name.inspect}"
      end

      package_name
    end

    def conformance_work_dir(package_name) = File.join(CONFORMANCE_ROOT, validate_package_name!(package_name))
    def package_dir(package_name) = File.join(conformance_work_dir(package_name), "package")
    def kdm_path(package_name) = File.join(conformance_work_dir(package_name), "kdm.json")
  end
end
