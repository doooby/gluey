
class Gluey::Material

  attr_reader :name, :glue, :paths, :items
  attr_accessor :asset_extension, :file_extension

  def initialize(name, glue, context)
    @name = name.to_sym
    @glue = glue
    @context = context

    set({asset_extension: name.to_s, paths: [], items: []})
    yield self if block_given?
    @file_extension ||= @asset_extension.dup
  end

  def set(**opts)
    allowed_options = %i(paths items asset_extension file_extension)
    opts.each do |k, value|
      next unless allowed_options.include? k
      instance_variable_set "@#{k}", value
    end
  end

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

  def find_base_file(path)
    full_paths.each do |base_path|
      p = "#{base_path}/#{path}.#{@file_extension}"; return p if File.exists? p
      p = "#{p}.erb"; return p if File.exists? p
      p = "#{base_path}/#{path}/index.#{@file_extension}"; return p if File.exists? p
      p = "#{p}.erb"; return p if File.exists? p
    end
    raise(::Gluey::FileNotFound.new "#{to_s} cannot find base file for #{path}")
  end

  def list_all_items
    list = []
    full_paths.map do |base_path|
      glob_path = "#{base_path}/**/*.#{@file_extension}"
      files = Dir[glob_path] + Dir["#{glob_path}.erb"]
      files.select do |file|
        path = file[/^#{base_path}\/(.+)\.#{@file_extension}(?:\.erb)?$/, 1]
        path.gsub! /\/index$/, ''
        list << path if is_listed? path, file
      end
    end
    list.uniq
  end

  private

  def full_paths
    @paths.map{|p| File.join @context.root, p}
  end

end