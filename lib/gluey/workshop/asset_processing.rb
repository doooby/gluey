module Gluey
  module AssetProcessing

    def fetch(material, path, mark=nil)
      material = material.is_a?(::Gluey::Material) ? material : self.material(material)
      raise("Unknown material #{material}!") unless material
      cache_key = "lump:#{material}:#{path}"

      # check cache
      file, dependencies = @cache[cache_key]
      if file && File.exists?(file) && !dependencies.any?{|d| d.changed?}
        return file, dependencies
      end

      # make / remake
      file, dependencies = make_asset material, path
      cache[cache_key] = [file, dependencies]
      return file, dependencies
    end

    def real_path(material_name, path)
      material = self.material material_name

      file = material.find_base_file path
      unless material.is_listed? path, file
        msg = "#{material.to_s} doesn't have enlisted item #{path} (#{file})."
        raise ::Gluey::ListingError.new(msg)
      end

      if mark_versions
        _, dependencies = fetch material, path
        digested_mark = Digest::MD5.new.digest dependencies.map(&:mark).join
        "#{path}.#{Digest.hexencode digested_mark}.#{material.asset_extension}"
      else
        "#{path}.#{material.asset_extension}"
      end
    end

    def make_asset(material, path)
      # prepare for processing
      base_file = material.find_base_file path
      file = "#{cache_path}/#{path}.#{material.asset_extension}"
      dependencies = [::Gluey::Dependencies::SingleFile.new(base_file).actualize]
      # process
      glue = material.glue.new self, material
      FileUtils.mkdir_p file[0..(file.rindex('/')-1)]
      glue.make file, base_file, dependencies
      return file, dependencies
    end

  end
end