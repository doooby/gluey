require 'sass'
require_relative 'script'

module Gluey::Glues
    class Sass < Script

      class << self
        attr_accessor :engine_opts
      end
      self.engine_opts = {line_comments: true}

      def process(base_file, deps)
        opts = self.class.engine_opts.merge syntax: @material.file_extension.to_sym,
            load_paths: [File.expand_path('..', base_file)],
            cache_store: ::Sass::CacheStores::Filesystem.new("#{@context.cache_path}/.sass"),
            filename: base_file

        engine = ::Sass::Engine.new super(base_file, deps), opts
        output = engine.render

        engine.dependencies.each do |dependency|
          deps << ::Gluey::Dependencies::SingleFile.new(dependency.options[:filename]).actualize
        end

        output
      end

    end
  end