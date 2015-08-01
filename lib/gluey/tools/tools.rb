require 'gluey/warehouse'

module Gluey::Tools

  def self.each_asset_file(workshop)
    warehouse = Gluey::Warehouse.new workshop.root_path
    warehouse.write_listing workshop
    warehouse.assets.each do |type, assets|
      assets.each do |path, real_path|
        cache_file = workshop.fetch_file type, path
        yield cache_file, type, real_path
      end
    end
  end



end