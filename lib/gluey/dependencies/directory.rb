require_relative 'single_file'

module Gluey::Dependencies
  class Directory < SingleFile

    def initialize(dir, dir_pattern=nil)
      @dir_pattern = "#{dir}/#{ dir_pattern || '**/*' }"
      super dir
    end

    def actualize
      @files_list = files_list
      super
    end

    def changed?
      @files_list != files_list
    end

    def exists?
      Dir.exists? @file
    end

    def files_list
      Dir[@dir_pattern]
    end

    def mark
      ''
    end

  end
end