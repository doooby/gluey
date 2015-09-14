
# Every isntance of this class holds together informations about
# some assets material for your app. (i.e. where to find pieces/files of your js code,
# how to put them together, what items are actually listed, which extension files have
# and which should have resulting assets, ...)
class Gluey::Material

  attr_reader :name, :glue, :paths, :items
  attr_accessor :asset_extension, :file_extension

  # @param [Symbol] name is used to identify the material
  # @param [Gluey::Glues::Base] glue an instance of a "glue" that processes pieces of material into the resulting asset
  # @param [Gluey::Environment] context an working environment
  def initialize(name, glue, context)
    @name = name.to_sym
    @glue = glue
    @context = context

    set({asset_extension: name.to_s, paths: [], items: []})
    yield self if block_given?
    @file_extension ||= @asset_extension.dup
  end

  # A convenient way to set up the material. You can specify these options:
  # +:paths+:: must be an array of relative paths (relative to environment base path)
  # +:items+:: array of items that will be processed with this materials. Either state :any, or a string
  #            matching to a file (without file extension as that is defined for the whole material), or
  #            a regexp or a proc (two argument yielded: 'path' of asset and full file path)
  # +:asset_extension+:: resulting extension of asset file - e.g. 'css' (this gets set to the same value
  #                      as is the name of the material before init block gets yielded)
  # +:file_extension+:: extension of material source files - e.g. 'sass' (this gets
  #                     set to the same value of asset_extension if not given inside init block)
  def set(**opts)
    allowed_options = %i(paths items asset_extension file_extension)
    opts.each do |k, value|
      next unless allowed_options.include? k
      instance_variable_set "@#{k}", value
    end
  end

  # Checks if the item in question is to be processed by this material. See {#set} for
  # what options there are to enlist items (/assets).
  # @param [String] path an asset's 'path'
  # @param [String] file actual base file path
  # @return [Boolean]
  def is_listed?(path, file)
    file[/\.(\w+)(?:\.erb)?$/, 1]==@file_extension &&
        @items.any? do |items_declaration|
          case items_declaration
            when :all, :any
              true
            when String
              path == items_declaration
            when Regexp
              path =~ items_declaration
            when Proc
              items_declaration[path, file]
          end
        end
  end

  def to_s
    "Material #{@name}"
  end

  # Tries to find the base file for asset's path. It can be direct path (extension specified
  # for the whole material), or a directory with 'index.*' file. Both options can have additional
  # *.erb extension.
  # @return [String] Path to base file.
  def find_base_file(path)
    full_paths.each do |base_path|
      p = "#{base_path}/#{path}.#{@file_extension}"; return p if File.exists? p
      p = "#{p}.erb"; return p if File.exists? p
      p = "#{base_path}/#{path}/index.#{@file_extension}"; return p if File.exists? p
      p = "#{p}.erb"; return p if File.exists? p
    end
    raise(::Gluey::FileNotFound.new "#{to_s} cannot find base file for #{path}")
  end

  # Returns an array of all assets paths, that is enlisted for this material (decided using {#is_listed?}).
  # For each asset a base file must exists to take it into account.
  def list_all_items
    list = []
    full_paths.map do |base_path|
      glob_path = "#{base_path}/**/*.#{@file_extension}"
      files = Dir[glob_path] + Dir["#{glob_path}.erb"]
      files.select do |file|
        path = file[/^#{base_path}\/(.+)\.#{@file_extension}(?:\.erb)?$/, 1]
        path.gsub! /\/index$/, ''
        if is_listed? path, file
          list << path
          true
        end
      end
    end
    list.uniq
  end

  private

  def full_paths
    @paths.map{|p| File.join @context.root, p}
  end

end