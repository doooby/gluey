require_relative '../gluey'
require 'json'

class Gluey::Warehouse

  attr_reader :root_path, :assets

  def initialize(root, listing="assets/glue_listing.json")
    @root_path = root
    @listing_file = "#{root}/#{listing}"
    read_listing
  end

  def real_path(asset_type, path)
    listing = @assets[asset_type]
    unless listing
      raise ::Gluey::ItemNotListed.new("Asset type #{asset_type} is not defined! (listing file problem?)")
    end

    real_path = listing[path]
    unless real_path
      raise ::Gluey::ItemNotListed.new("Unknown asset: #{path}, type=#{asset_type}! (listing file problem?)")
    end

    real_path
  end

  def read_listing
    assets = JSON.parse File.read(@listing_file) rescue {}
    @assets = assets.keys.inject({}){|h, asset_type| h[asset_type.to_sym] = assets[asset_type]; h }
  end

  def write_listing(workshop)
    @assets = workshop.materials.values.inject({}) do |listing, material|
      list = material.list_all_items.inject({}) do |h, path|
        h[path] = workshop.real_path material.name, path
        h
      end
      listing[material.name.to_s] = list
      listing
    end
    File.write @listing_file, JSON.pretty_generate(@assets)
  end

end