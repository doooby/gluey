require 'digest'

require_relative '../gluey'
require_relative 'common/url_helper'

require_relative 'exceptions/item_not_listed'
require_relative 'exceptions/file_not_found'

require_relative 'workshop/material'
require_relative 'workshop/glues/base'

class Gluey::Workshop
  include Gluey::UrlHelper

  attr_reader :root_path, :tmp_path, :materials, :cache
  attr_accessor :mark_versions

  def initialize(root, tmp_dir='tmp/gluey')
    @root_path = root
    @tmp_path = "#{root}/#{tmp_dir}"
    Dir.mkdir @tmp_path unless Dir.exists? @tmp_path
    @materials = {}
    @cache = {}
  end

  def register_material(name, glue=::Gluey::Glues::Base, &block)
    name = name.to_sym
    raise "Material #{name} already registered!" if @materials[name]
    material = ::Gluey::Material.new name, glue, self, &block
    material.items << :any if material.items.empty?
    @materials[name] = material
  end

  def fetch_asset(material, path)
    material = material.is_a?(::Gluey::Material) ? material : @materials[material.to_sym]
    raise("Unknown material #{material}!") unless material

    m = path.match /^([^\.]+)\.(?:[a-f0-9]{32}\.)?(\w+)$/
    raise "Bad asset path: #{path}" unless m
    cache_key = "lump:#{material}:#{path}"

    # check cache
    file, dependencies = @cache[cache_key]
    if file && File.exists?(file) && !dependencies.any?{|d| d.changed?}
      return file, dependencies
    end

    # make / remake
    file, dependencies = make_asset material, path
    @cache[cache_key] = [file, dependencies]
    return file, dependencies
  end

  def get_binding
    binding
  end

  # non public

  def real_path(material_name, path)
    material = @materials[material_name.to_sym] || raise("Unknown material #{material_name}!")

    file = material.find_base_file path
    unless material.is_listed? path, file
      raise ::Gluey::ItemNotListed.new("#{material.to_s} doesn't have enlisted item #{path} (file=#{file}).")
    end

    if mark_versions
      _, dependencies = fetch_asset material, path
      digested_mark = Digest::MD5.new.digest dependencies.map(&:mark).join
      "#{path}.#{Digest.hexencode digested_mark}.#{material.asset}"
    else
      "#{path}.#{material.asset}"
    end
  end

  def make_asset(material, path)
    # prepare for processing
    base_file = material.find_base_file path
    file = "#{@tmp_path}/#{path}.#{material.asset}"
    dependencies = [::Gluey::Dependencies::SingleFile.new(base_file).actualize]
    # process
    glue = material.glue.new self, material
    FileUtils.mkdir_p file[0..(file.rindex('/')-1)]
    glue.make file, base_file, dependencies
    return file, dependencies
  end

end