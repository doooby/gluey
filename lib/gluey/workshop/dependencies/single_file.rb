module Gluey::Dependencies
  class SingleFile

    attr_reader :file, :data

    def initialize(file, **data)
      @file = file
      @data = data
    end

    def actualize
      @mtime = File.mtime(@file).to_i
      self
    end

    def changed?
      File.mtime(@file).to_i != @mtime rescue true
    end

    def exists?
      File.exists? @file
    end

    def ==(other)
      @file == other.file
    end

    def mark
      File.mtime(@file).to_i.to_s
    end

  end
end