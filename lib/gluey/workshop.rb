require 'digest'
require_relative '../gluey'
require_relative 'url'

require_relative 'exceptions/item_not_listed'

require_relative 'material'
require_relative 'glues/base'

class Gluey::Workshop
  include Gluey::Url

  attr_reader :root_path, :tmp_path, :materials, :cache
  attr_accessor :base_url

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
    material.items << :any if material.items.empty?
    @materials[name] = material
  end

  def fetch_file(material, path)
    # check cache
    cache_key = chache_asset_key material, path
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
    glue.make file, base_file, dependencies

    # save and return
    @cache[cache_key] = [file, dependencies]
    file
  end

  def real_path(material, path, digest_mark=false)
    material = @materials[material.to_sym]
    file = material.find_base_file path
    unless material.is_listed? path, file
      raise ::Gluey::ItemNotListed.new("#{material.to_s} doesn't have enlisted item #{path} (file=#{file}).")
    end
    if digest_mark
      fetch_file material.name, path
      cache_key = chache_asset_key material.name, path
      file, dependencies = @cache[cache_key]
      digested_mark = Digest::MD5.new.digest dependencies.map(&:mark).join
      "#{path}.#{Digest.hexencode digested_mark}.#{material.asset}"
    else
      "#{path}.#{material.asset}"
    end
  end

  def try_real_path(path)
    path.match /^(.+)\.(?:[a-f0-9]{32}\.)(\w+)$/ do |m|
      yield m[1], m[2]
    end
  end

  def get_binding
    binding
  end

  private

  def chache_asset_key(material, path)
    "lump:#{material}:#{path}"
  end

end