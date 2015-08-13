module Gluey
  module AssetRetrieving
    MARK_PARSER = %r_^[^\.]+\.(?:([a-f0-9]{32})\.)?\w+$_

    def real_path(asset_type, path)
      list = @listing[asset_type]
      raise ::Gluey::ListingError.new("Asset type #{asset_type} is not defined!") unless list

      real_path = list[path]
      raise ::Gluey::ListingError.new("Unknown asset: #{path}, type=#{asset_type}!") unless real_path

      real_path
    end

    def fetch(asset_type, path, mark=nil)
      extant_path = real_path asset_type, path
      return unless mark == extant_path.match(MARK_PARSER)[1]

      file = "#{assets_path}/#{asset_type}/#{extant_path}"
      file if File.exists? file

    rescue ::Gluey::ListingError
      nil
    end

    def assets_path
      @assets_path ||= "#{root}/public#{path_prefix}"
    end

  end
end