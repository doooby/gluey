require_relative 'script'
require_relative '../dependencies/texts_bundle'

module Gluey::Glues
  class JsScript < Script

    def post_strict(_)
      @output = "'use strict';\n#{@output}"
    end

    def post_enclose(_)
      @output = "(function(){\n#{@output}\n}());"
    end

    def post_strict_mode(_)
      @output = "'use strict';\n#{@output}"
    end

    def pre_replace(args)
      file = find_nested_file(args[1])
      cached_file, deps = get_nested_piece file
      @dependencies.concat deps
      @script.gsub! /"%#{args[0]}%"/, File.read(cached_file)
    end

    def pre_return(args)
      @script = "#{@script}\nreturn #{args.first};"
    end

    def post_return(_)
      @output = "(function(){\n#{@output}\n}())"
    end

    def pre_replace_with_texts_bundle(args)
      dir = File.expand_path("../#{args[1]}", @base_file)
      raise "cannot find relative path #{args[1]} for script=#{@base_file}" unless dir && Dir.exists?(dir)

      logical_path = dir[/(?:^#{@context.root}\/)?(.+)$/, 1]
      key = "dep:txt_bundle:#{logical_path}:#{@material.name}"
      hb_dep = @context.cache[key]
      unless hb_dep
        hb_dep = ::Gluey::Dependencies::TextsBundle.new dir, logical_path, @context
        @context.cache[key] = hb_dep
      end

      hb_dep.actualize if hb_dep.changed?
      @dependencies << hb_dep
      @script.gsub! /"%#{args[0]}%"/, File.read(hb_dep.file)
    end

  end
end