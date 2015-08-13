require_relative 'directory'

module Gluey::Dependencies
  class TextsBundle < SingleFile
    JS_ESCAPE_MAP = {
        '\\'    => '\\\\',
        "\r\n"  => '\n',
        "\n"    => '\n',
        "\r"    => '\n',
        '"'     => '\\"',
        "'"     => "\\'"
    }

    def initialize(dir, logical_path, context)
      tmp_dir = "#{context.cache_path}/.texts_bundle"
      Dir.mkdir tmp_dir unless Dir.exists? tmp_dir
      @cache_path = "#{tmp_dir}/#{logical_path.gsub '/', '-'}"
      Dir.mkdir @cache_path unless Dir.exists? @cache_path

      @dir_dep = ::Gluey::Dependencies::Directory.new(dir, '**/*')
      @dependencies = []
      super "#{@cache_path}.texts_bundle"
    end

    def changed?
      @dependencies.any?{|d| d.changed?} || @dir_dep.changed? || (File.mtime(@file).to_i != @mtime rescue true)
    end

    def mark
      @dependencies.map(&:mark).join
    end

    def actualize
      # remove deleted files
      @dependencies.delete_if{|dep| !dep.exists? }
      # add new files
      new_files = (@dir_dep.files_list - @dependencies.map(&:file)).map do |f|
        text_name = f[/#{@dir_dep.file}\/(.+)$/, 1]
        ::Gluey::Dependencies::SingleFile.new f, text_name: text_name
      end
      @dependencies.concat new_files
      @dir_dep.actualize
      @dependencies.each{|dep| dep.actualize if dep.changed? }

      write_bundle
      @mtime = File.mtime(@file).to_i
      self
    end

    private

    def write_bundle
      File.open @file, 'w' do |f|
        f.write '{'
        @dependencies.each_with_index do |dep, i|
          f.write "#{', ' if i!=0}\"#{dep.data[:text_name]}\": "
          text = File.read dep.file
          text.gsub!(/(\\|\r\n|[\n\r"'])/u){|match| JS_ESCAPE_MAP[match] }
          f.write "\"#{text}\""
        end
        f.write '}'
      end
    end

  end
end