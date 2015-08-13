require 'gluey'
require_relative 'workshop/material'
require_relative 'workshop/glues/base'

require 'digest'
require_relative 'base/environment'

module Gluey
  class Workshop < Environment

    require_relative 'workshop/asset_processing'
    include AssetProcessing

    attr_reader :cache_path, :cache

    def initialize(root, cache_path='tmp/gluey', **opts, &block)
      super opts.merge!(
                root: root,
                cache_path: "#{root}/#{cache_path}",
                materials: {},
                cache: {}
            ), &block
      FileUtils.mkdir_p @cache_path
    end

    def material(name)
      @materials[name.to_sym] || raise(UnregisteredMaterial.new "Unknown material #{name}.")
    end

    def register_material(name, glue=::Gluey::Glues::Base, &block)
      name = name.to_sym
      raise "Material #{name} already registered!" if @materials[name]

      material = ::Gluey::Material.new name, glue, self, &block
      material.items << :any if material.items.empty?
      @materials[name] = material
    end

    def get_binding
      binding
    end

  end
end