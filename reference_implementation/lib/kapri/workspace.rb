require "fileutils"

module Kapri
  # Keeps the immutable Package Container separate from delivery artifacts,
  # implementation state, validation reports and decrypted output.
  module Workspace
    module_function

    def package_dir(work_dir)
      nested = File.join(work_dir, "package")
      File.directory?(nested) ? nested : work_dir
    end

    def ensure_package_dir(work_dir)
      path = File.join(work_dir, "package")
      FileUtils.mkdir_p(path)
      path
    end

    def state_dir(work_dir)
      File.join(artifact_dir(work_dir), "state")
    end

    def state_path(work_dir, filename)
      File.join(state_dir(work_dir), filename)
    end

    def kdm_path(work_dir)
      File.join(artifact_dir(work_dir), "kdm.json")
    end

    def report_path(work_dir)
      File.join(artifact_dir(work_dir), "validation-report.json")
    end

    def decrypted_dir(work_dir)
      File.join(artifact_dir(work_dir), "decrypted")
    end

    def artifact_dir(work_dir)
      File.directory?(File.join(work_dir, "package")) ? work_dir : File.dirname(File.expand_path(work_dir))
    end
  end
end
