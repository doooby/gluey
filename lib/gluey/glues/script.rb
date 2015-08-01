require_relative '../dependencies/single_file'

module Gluey::Glues
  class Script < Base

    PREFIXES = ['//'].map{|p| Regexp.escape(p)}
    DIRECTIVES_REGEXP = Regexp.compile "\\A(?:\\s*#{PREFIXES.map{|p| "(?:#{p}=.*\\n?)+"}.join '|'})+"

    def process(base_file, deps)
      @script, @directives = strip_directives read_base_file(base_file)
      return @script unless @directives
      @dependencies = deps
      @output = ''
      @base_file = base_file
      @marks = {append_self: ->{ @output += @script }}
      @directives.each{|args| directive args, :pre }
      @marks[:append_self].call if @marks[:append_self]
      @directives.each{|args| directive args, :post }
      @output
    end

    def pre_prepend(args)
      file = find_nested_file(args.first)
      cached_file, deps = get_nested_piece file
      @dependencies.concat deps
      @script = "#{File.read cached_file}#{@script}"
    end

    def pre_append(args)
      file = find_nested_file(args.first)
      cached_file, deps = get_nested_piece file
      @dependencies.concat deps
      @script = "#{@script}#{File.read cached_file}"
    end

    def pre_depend_on(args)
      file = find_nested_file(args[1])
      @dependencies << ::Gluey::Dependencies::SingleFile.new(file).actualize
    end

    private

    def strip_directives(data)
      script = data
      directives = data[DIRECTIVES_REGEXP]
      if directives
        script = $'
        directives = directives.split("\n").reject{|dir| dir.empty?}.map do |dir|
          dir.strip[/(?:#{PREFIXES.join '|'}=)\s*(.+)/, 1].split (' ')
        end
      end
      return script, directives
    end

    def directive(dir_array, run)
      method = "#{run}_#{dir_array.first}"
      send method, dir_array[1..-1] if respond_to? method
    end

    def find_nested_file(rel_path)
      file = File.expand_path("../#{rel_path}", @base_file)
      File.exists?(file) || raise("cannot find '#{rel_path}' from script=#{@base_file}")
      file
    end

    def get_nested_piece(file)
      path = file[/(?:^#{@context.root_path}\/)?(.+)$/, 1]
      key = "script_piece:#{@material.name}:#{path}"
      cache_file, dependencies = @context.cache[key]
      return cache_file, dependencies if cache_file && File.exists?(cache_file) && !dependencies.any?{|dep| dep.changed?}

      glue = self.class.new @context, @material
      cache_dir = "#{@context.tmp_path}/.script"
      Dir.mkdir cache_dir unless Dir.exists? cache_dir
      cache_file = "#{cache_dir}/#{path}.#{@material.name}"
      dependencies = [::Gluey::Dependencies::SingleFile.new(file).actualize]
      FileUtils.mkdir_p cache_file[0..(cache_file.rindex('/')-1)]
      File.write cache_file, glue.process(file, dependencies)
      @context.cache[key] = [cache_file, dependencies]
      return cache_file, dependencies
    end

  end
end