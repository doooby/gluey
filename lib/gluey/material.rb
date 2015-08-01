require_relative 'exceptions/file_not_found'

class Gluey::Material

  attr_reader :name, :glue
  attr_accessor :asset, :file_extension, :public_dir

  def initialize(name, glue, context)
    @name = name.to_sym
    @glue = glue
    @context = context
    @asset = name.to_s
    @paths = []
    @items = []
    yield self if block_given?
    @file_extension ||= @asset.dup
  end

  def add_path(path)
    @paths << path
  end

  def add_item(declaration)
    @items << declaration
  end

  def is_listed?(path, file=nil)
    @items.any? do |items_declaration|
      case items_declaration
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
    paths.each do |base_path|
      p = "#{base_path}/#{path}.#{@file_extension}"; return p if File.exists? p
      p = "#{p}.erb"; return p if File.exists? p
      p = "#{base_path}/#{path}/index.#{@file_extension}"; return p if File.exists? p
      p = "#{p}.erb"; return p if File.exists? p
      end
    raise(::Gluey::FileNotFound.new "#{to_s} cannot find base file for #{path}")
  end

  def list_all_items
    list = []
    paths.map do |base_path|
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

  def paths
    @paths.map{|p| "#{@context.root_path}/#{p}"}
  end

end