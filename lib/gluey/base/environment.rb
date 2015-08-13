module Gluey

  class Environment

    attr_reader :root, :base_url, :path_prefix
    attr_accessor :mark_versions

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

    def asset_url(material, path)
      "#{base_url}#{path_prefix}/#{material}/#{real_path material, path}"
    end

    def [](material, path, mark=nil)
      fetch(material, path, mark)[0]
    end
    alias_method :find_asset_file, :[]

  end

end