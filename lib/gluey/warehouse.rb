require 'json'
require_relative 'warehouse/asset_retrieving'

module Gluey
  class Warehouse < Environment
    include ::Gluey::AssetRetrieving

    attr_reader :listing

    def initialize(root, listing_path='assets/gluey_listing.json', **opts, &block)
      super opts.merge!(
                root: root,
                listing_file: "#{root}/#{listing_path}",
            ), &block
      @assets_path = "#{root}/#{@assets_path.chomp '/'}#{path_prefix}" if @assets_path && @assets_path[0]!='/'
      read_listing
    end

    def read_listing
      @listing = if File.exists? @listing_file
                   @listing = JSON.parse File.read(@listing_file) rescue nil
                   unless @listing.is_a? Hash
                     raise ::Gluey::ListingError.new("Corrupted listing file at #{@listing_file} !")
                   end
                   Hash[@listing.map{|k, v| [k.to_sym, v]}]
                 else
                   {}
                 end
    end

    def write_listing(workshop)
      @listing = workshop.materials.values.inject({}) do |listing, material|
        list = material.list_all_items.inject({}) do |h, path|
          h[path] = workshop.real_path material.name, path
          h
        end
        listing[material.name] = list
        listing
      end
      File.write @listing_file, JSON.pretty_generate(@listing)
    end

    def each_listed_asset(workshop)
      @listing.each do |asset_type, list|
        list.each do |path, real_path|
          yield workshop[asset_type, path], real_path, workshop.material(asset_type)
        end
      end
    end

  end
end