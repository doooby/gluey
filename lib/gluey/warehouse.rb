require_relative '../gluey'
require_relative 'url'
require_relative 'exceptions/item_not_listed'
require 'json'

class Gluey::Warehouse
  include Gluey::Url

  attr_reader :assets

  def initialize(root, listing_file='assets/gluey_listing.json')
    @listing_file = "#{root}/#{listing_file}"
    read_listing
  end

  def real_path(asset_type, path, mark=nil)
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
    assets = if File.exists? @listing_file
               JSON.parse File.read(@listing_file) rescue {}
             else
               {}
             end
    raise "corrupted listing file at #{@listing_file}" unless assets.is_a? Hash
    @assets = assets.keys.inject({}){|h, asset_type| h[asset_type.to_sym] = assets[asset_type]; h }
  end

  def write_listing(workshop)
    @assets = workshop.materials.values.inject({}) do |listing, material|
      list = material.list_all_items.inject({}) do |h, path|
        h[path] = workshop.real_path material.name, path, true
        h
      end
      listing[material.name.to_sym] = list
      listing
    end
    File.write @listing_file, JSON.pretty_generate(@assets)
  end

end