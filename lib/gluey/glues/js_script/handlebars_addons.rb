require_relative '../../dependencies/handlebars_bundle'

module Gluey::Glues
  class JsScript < Script

    def pre_replace_with_handlebars(args)
      dir = File.expand_path("../#{args[1]}", @base_file)
      raise "cannot find dir containing handlebars templates for script=#{@base_file}" unless dir && Dir.exists?(dir)

      logical_path = dir[/(?:^#{@context.root_path}\/)?(.+)$/, 1]
      key = "dep:hb_bundle:#{logical_path}:#{@material.name}"
      hb_dep = @context.cache[key]
      unless hb_dep
        hb_dep = ::Gluey::Dependencies::Handlebars_bundle.new dir, logical_path, @context
        @context.cache[key] = hb_dep
      end

      hb_dep.actualize if hb_dep.changed?
      @dependencies << hb_dep
      @script.gsub! /"%#{args[0]}%"/, File.read(hb_dep.file)
    end

  end
end