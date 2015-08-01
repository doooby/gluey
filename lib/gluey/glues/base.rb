module Gluey::Glues
  class Base

    def initialize(context, material)
      @context = context
      @material = material
    end

    def process(base_file, dependecies)
      read_base_file base_file
    end

    def read_base_file(file)
      raw_content = File.read(file)
      file[-4..-1]=='.erb' ? ERB.new(raw_content).result : raw_content
    end

  end
end