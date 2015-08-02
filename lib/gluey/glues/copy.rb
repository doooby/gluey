module Gluey::Glues
  class Copy < Base

    def make(new_file, base_file, dependencies)
      FileUtils.cp base_file, new_file
    end

  end
end