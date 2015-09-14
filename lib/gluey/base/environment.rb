module Gluey

  # This encapsulates informations needed to process assets. This is just base class,
  # there are specific environments for both developement ({Gluey::Workshop})
  # and production ({Gluey::Warehouse}).
  class Environment

    # @return [String] Root path for files (to which material's paths are relative).
    attr_reader :root

    # @return [String] Url that will be used to refer to assets (see usage inside {#asset_url}).
    attr_reader :base_url

    # @return [String] Prefix to assets path (defaults to '/assets').
    attr_reader :path_prefix

    # @return [Bollean] Wether assets should have version mark (for cache-busting).
    attr_accessor :mark_versions

    # Creates new instance using options hash and/or block executed upon the instance.
    # After the initialization, root path must be defined or an error is raised.
    # @param [Hash] opts is used to set according attributes.
    def initialize(**opts, &block)
      opts = {
          base_url: nil,
          path_prefix: '/assets'
      }.merge! opts

      opts.each do |k, value|
        next unless k.is_a? Symbol
        instance_variable_set "@#{k}", value
      end
      instance_exec &block if block

      root || raise('Root directory not defined!')
    end

    # Wrapper to generate asset's url - #real_path must be defined in the subclass
    # (like in workshop's {Gluey::AssetProcessing#real_path}).
    # @param [String, Symbol] material Name refering to some material.
    # @param [String] path Relative path to asset.
    # @return [String] Url that refers to according asset;
    def asset_url(material, path)
      "#{base_url}#{path_prefix}/#{material}/#{real_path material, path}"
    end

    # Fetches asset's base file - standard wrapper for subclass environments.
    # Need #fetch method to be defined in subclass.
    # @param [String, Symbol] material Name refering to some material.
    # @param [String] path Relative path to asset.
    # @param [String] mark Version mark (optional, usage depends on #fetch of subclass).
    def [](material, path, mark=nil)
      fetch(material, path, mark)[0]
    end
    alias_method :find_asset_file, :[]

  end

end