require 'gluey/warehouse'

module Gluey::Tools

  def self.each_asset_file(workshop, warehouse)
    warehouse.assets.each do |type, assets|
      assets.each do |path, real_path|
        cache_file = workshop.fetch_file type, path
        yield cache_file, type, real_path
      end
    end
  end

  def self.create_uglifier_builder(**opts)
    require 'uglifier'
    ->(a, b){File.write b, ::Uglifier.new(opts.merge! copyright: :none).compile(File.read a)}
  end

end