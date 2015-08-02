require_relative 'tools'

module Gluey::Tools

  def self.build_into_public_dir(workshop, warehouse, public_dir='public/assets', **builders)
    public_dirs = workshop.materials.values.inject({}) do |h, m|
      h[m.name] = "#{workshop.root_path}/#{m.public_dir || public_dir}"
      h
    end

    built = []
    move_it = -> (cache_file, file) { FileUtils.mv cache_file, file }
    self.each_asset_file workshop, warehouse do |cache_file, type, path|
      file = "#{public_dirs[type]}/#{path}"
      next if File.exists? file
      FileUtils.mkdir_p file[0..(file.rindex('/')-1)]
      (builders[type] || move_it)[cache_file, file]
      built << file
      puts "created #{file}"
    end
    return built
  end

  def self.clear_public_dir(workshop, warehouse, versions=2, public_dir='public/assets')
    public_dirs = workshop.materials.values.inject({}) do |h, m|
      h[m.name] = "#{workshop.root_path}/#{m.public_dir || public_dir}"
      h
    end

    # process existing files into assets
    eas_regexp = /^#{workshop.root_path}\/(.+)$/
    assets = public_dirs.values.uniq.map{|dir| Dir["#{dir}/**/*.*.*"]}.flatten.
        map{|f| Asset.try_create f[eas_regexp, 1]}.compact
    assets = assets.inject({}){|h, asset| (h[asset.path] ||= []) << asset; h }

    # items not on list
    on_list = []
    warehouse.assets.each do |type, mater_assets|
      mater_assets.each do |_, real_path|
        file = "#{public_dirs[type]}/#{real_path}"
        asset = Asset.try_create file[eas_regexp, 1]
        on_list << asset
      end
    end
    on_list.map! &:path
    assets.delete_if do |path, asseets_arr|
      unless on_list.include? path
        asseets_arr.each do |some_asset|
          file = "#{workshop.root_path}/#{some_asset.orig_path}"
          File.delete file
          puts "deleted unknown #{file}"
        end
        true
      end
      false
    end

    # older versions
    assets.values.select{|arr| arr.length > versions}.
        map{|arr| arr.sort.slice 0..(-versions-1) }.compact.flatten.each do |old_asset|
      file = "#{workshop.root_path}/#{old_asset.orig_path}"
      File.delete file
      puts "deleted old #{file}"
    end
  end

  class Asset < Struct.new(:path, :time_stamp)

    def self.try_create(file)
      file.match /^([^\.]+)\.(\d+)\.(\w+)$/ do |m|
        new "#{m[1]}.#{m[3]}", m[2]
      end
    end

    def <=>(other)
      time_stamp <=> other.time_stamp
    end

    def orig_path
      ret = path.dup
      ret.insert ret.rindex('.'), ".#{time_stamp}"
    end

  end

end