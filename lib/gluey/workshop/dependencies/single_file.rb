module Gluey::Dependencies
  class SingleFile

    # Path to file (or possibly directory) that'll be watched for FS mtime changes
    attr_reader :file

    # Custom data
    attr_reader :data

    def initialize(file, **data)
      @file = file
      @data = data
    end

    # Reads mtime of the file
    # @return self
    def actualize
      @mtime = File.mtime(@file).to_i
      self
    end

    # Wether the file's mtime changed since last #actualize was called. Returns true if file
    # doesn't exists.
    def changed?
      File.mtime(@file).to_i != @mtime rescue true
    end

    # Wether the file exists.
    def exists?
      File.exists? @file
    end

    # Comparing using file attribute.
    def ==(other)
      @file == other.file
    end

    # generate version mark for this dependency.
    # @return [String]
    def mark
      File.mtime(@file).to_i.to_s
    end

  end
end