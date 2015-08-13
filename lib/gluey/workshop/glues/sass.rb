require 'sass'
require_relative 'script'

module Gluey::Glues
    class Sass < Script

      def process(base_file, deps)
        opts = {
            syntax: @material.file_extension.to_sym,
            load_paths: [File.expand_path('..', base_file)],
            cache_store: ::Sass::CacheStores::Filesystem.new("#{@context.cache_path}/.sass"),
            filename: base_file,
            line_comments: true
        }
        engine = ::Sass::Engine.new super(base_file, deps), opts
        output = engine.render

        engine.dependencies.each do |dependency|
          deps << ::Gluey::Dependencies::SingleFile.new(dependency.options[:filename]).actualize
        end

        output
      end

    end
  end