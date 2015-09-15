require 'erb'

module Gluey::Glues

  # A glue costitutes the way materials shall be processed. This is the base class shaping common api.
  # The process of "gluing" of asset is invoked within workshop's {Gluey::AssetProcessing#make_asset}.
  class Base

    # @param [Gluey::Environment] context
    # @param [Gluey::Material] material
    def initialize(context, material)
      @context = context
      @material = material
    end

    # If not overrided in subclass, writes output of {#process} into specified file.
    def make(new_file, base_file, dependencies)
      File.write new_file, process(base_file, dependencies)
    end

    # Processes base file accordingly and notes dependent files.
    # If not overrided in subclass, simply outputs the content of base file.
    def process(base_file, dependecies)
      read_base_file base_file
    end

    # Reads the file. (if the file has extension *.erb then process through ruby templating first)
    def read_base_file(file)
      raw_content = File.read(file)
      file[-4..-1]=='.erb' ? ERB.new(raw_content).result(@context.get_binding) : raw_content
    end

  end

  # Convenient way to require glues for use. Requires particular file, perhaps addons for that class,
  # and return constant of that glue.
  # @param [String] name relative file containing requested glue - it must define respective constant
  # @param [Array<String>] addons_names list of addons files that modifies requested glue class
  # @return [Gluey::Glues::Base]
  def self.load(name, *addons_names)
    glue = File.expand_path("../#{name}", __FILE__)
    require glue
    addons_names.flatten.each{|an| require "#{glue}/#{an}_addons" }
    ::Gluey::Glues.const_get name.split('_').map(&:capitalize).join
  rescue LoadError => e
    raise "#{e.message}\n -- missing dependency? (are you using bundler?)"
  end

end