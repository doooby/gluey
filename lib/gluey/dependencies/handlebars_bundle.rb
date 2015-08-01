require 'handlebars'
require_relative 'directory'

module Gluey::Dependencies
  class Handlebars_bundle < SingleFile

    def initialize(dir, logical_path, context)
      tmp_dir = "#{context.tmp_path}/.texts_bundle"
      Dir.mkdir tmp_dir unless Dir.exists? tmp_dir
      @cache_path = "#{tmp_dir}/#{logical_path.gsub '/', '-'}"
      Dir.mkdir @cache_path unless Dir.exists? @cache_path

      @dir_dep = ::Gluey::Dependencies::Directory.new(dir, '**/*.hb')
      @dependencies = []
      super "#{@cache_path}.hb_bundle"
    end

    def changed?
      @dependencies.any?{|d| d.changed?} || @dir_dep.changed? || (File.mtime(@file).to_i != @mtime rescue true)
    end

    def actualize
      # remove deleted files
      @dependencies.delete_if{|dep| !dep.exists? }
      # add new files
      new_files = (@dir_dep.files_list - @dependencies.map(&:file)).map do |f|
        template = f[/#{@dir_dep.file}\/(.+)\.hb$/, 1]
        ::Gluey::Dependencies::SingleFile.new f, template: template,
                                                  hb_precompiled: "#{@cache_path}/#{template.gsub '/', '-'}"
      end
      @dependencies.concat new_files
      @dir_dep.actualize

      # re-precompile changed
      handlebars_context = ::Handlebars::Context.new
      @dependencies.each do |dep|
        next if !dep.changed? && File.exists?(dep.data[:hb_precompiled])
        dep.actualize
        precompile_output = handlebars_context.precompile File.read(dep.file)
        File.write dep.data[:hb_precompiled], precompile_output
      end

      write_bundle
      @mtime = File.mtime(@file).to_i
      self
    end

    private

    def write_bundle
      File.open @file, 'w' do |f|
        f.write '{'
        @dependencies.each_with_index do |dep, i|
          f.write "#{', ' if i!=0}\"#{dep.data[:template]}\": "
          f.write File.read(dep.data[:hb_precompiled])
        end
        f.write '}'
      end
    end

  end
end