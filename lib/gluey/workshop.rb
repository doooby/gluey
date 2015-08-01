require_relative '../gluey'

require_relative 'exceptions/item_not_listed'

require_relative 'material'
require_relative 'glues/base'

class Gluey::Workshop

  attr_reader :root_path, :tmp_path, :materials, :cache

  def initialize(root, tmp_dir='tmp/gluey')
    @root_path = root
    @tmp_path = "#{root}/#{tmp_dir}"
    Dir.mkdir @tmp_path unless Dir.exists? @tmp_path
    @materials = {}
    @cache = {}
  end

  def register_material(name, glue=::Gluey::Glues::Base, &block)
    name = name.to_sym
    material = ::Gluey::Material.new name, glue, self, &block
    @materials[name] = material
  end

  def fetch_file(material, path)
    # check cache
    cache_key = "lump:#{material}:#{path}"
    file, dependencies = @cache[cache_key]
    if file && File.exists?(file) && !dependencies.any?{|d| d.changed?}
      return file
    end

    # prepare for processing
    material = @materials[material.to_sym]
    base_file = material.find_base_file path
    file = "#{@tmp_path}/#{path}.#{material.asset}"
    dependencies = [::Gluey::Dependencies::SingleFile.new(base_file).actualize]
    # process
    glue = material.glue.new self, material
    FileUtils.mkdir_p file[0..(file.rindex('/')-1)]
    File.write file, glue.process(base_file, dependencies)

    # save and return
    @cache[cache_key] = [file, dependencies]
    file
  end

  def real_path(material, path)
    material = @materials[material.to_sym]
    file = material.find_base_file path
    unless material.is_listed? path, file
      raise ::Gluey::ItemNotListed.new("#{material.to_s} doesn't have enlisted item #{path} (file=#{file}).")
    end
    "#{path}.#{File.mtime(file).to_i}.#{material.asset}"
  end

  def try_real_path(path)
    path.match /^(.+)\.\d+\.(\w+)$/ do |m|
      yield m[1], m[2]
    end
  end

end