module Gluey::Glues
  class Base

    def initialize(context, material)
      @context = context
      @material = material
    end

    def make(new_file, base_file, dependencies)
      File.write new_file, process(base_file, dependencies)
    end

    def process(base_file, dependecies)
      read_base_file base_file
    end

    def read_base_file(file)
      raw_content = File.read(file)
      file[-4..-1]=='.erb' ? ERB.new(raw_content).result(@context.get_binding) : raw_content
    end

  end

  def self.load(name, *addons_names)
    glue = File.expand_path("../#{name}", __FILE__)
    require glue
    addons_names.flatten.each{|an| require "#{glue}/#{an}_addons" }
    ::Gluey::Glues.const_get name.split('_').map(&:capitalize).join
  rescue LoadError => e
    raise "#{e.message}\n -- missing dependency? (are you using Gemfile?)"
  end

end