
module Gluey::Tools

  def self.each_asset_file(workshop, warehouse)
    warehouse.assets.each do |type, assets|
      assets.each do |path, real_path|
        cache_file, _ = workshop.fetch type, path
        yield cache_file, type, real_path
      end
    end
  end

  def self.create_uglifier_builder(**opts)
    require 'uglifier'
    uglifier = ::Uglifier.new({copyright: :none}.merge! opts)
    ->(a, b){File.write b, uglifier.compile(File.read a)}
  end

end