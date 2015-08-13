
module Gluey::Tools

  def self.make_into_assets_dir(workshop, warehouse)
    made = []

    warehouse.each_listed_asset workshop do |cache_file, path, material|
      file = "#{warehouse.assets_path}/#{material.name}/#{path}"
      next if File.exists? file

      FileUtils.mkdir_p file[0..(file.rindex('/')-1)]
      FileUtils.cp cache_file, file

      made << file
      puts "created #{file}"
    end

    made
  end

  # def self.clear_public_dir(workshop, warehouse, versions=3, public_dir='public/assets')
  #   public_dirs = workshop.materials.values.inject({}) do |h, m|
  #     h[m.name] = "#{workshop.root_path}/#{m.public_dir || public_dir}"
  #     h
  #   end
  #
  #   # process existing files into assets
  #   eas_regexp = /^#{workshop.root_path}\/(.+)$/
  #   assets = public_dirs.values.uniq.map{|dir| Dir["#{dir}/**/*.*.*"]}.flatten.
  #       map{|f| Asset.try_create f[eas_regexp, 1], f}.compact
  #   assets = assets.inject({}){|h, asset| (h[asset.path] ||= []) << asset; h }
  #
  #   # items not on list
  #   on_list = []
  #   warehouse.assets.each do |type, mater_assets|
  #     mater_assets.each do |_, real_path|
  #       file = "#{public_dirs[type]}/#{real_path}"
  #       asset = Asset.try_create file[eas_regexp, 1], f
  #       on_list << asset
  #     end
  #   end
  #   on_list.map! &:path
  #   assets.delete_if do |path, asseets_arr|
  #     unless on_list.include? path
  #       asseets_arr.each do |some_asset|
  #         file = "#{workshop.root_path}/#{some_asset.orig_path}"
  #         File.delete file
  #         puts "deleted unknown #{file}"
  #       end
  #       true
  #     end
  #     false
  #   end
  #
  #   # older versions
  #   assets.values.select{|arr| arr.length > versions}.
  #       map{|arr| arr.sort.slice 0..(-versions-1) }.compact.flatten.each do |old_asset|
  #     file = "#{workshop.root_path}/#{old_asset.orig_path}"
  #     File.delete file
  #     puts "deleted old #{file}"
  #   end
  # end
  #
  # class Asset < Struct.new(:path, :time_stamp)
  #
  #   def self.try_create(path, file)
  #     path.match /^([^\.]+)\.(?:[a-f0-9]{32}\.)?(\w+)$/ do |m|
  #       new "#{m[1]}.#{m[2]}", File.mtime(file).to_i
  #     end
  #   end
  #
  #   def <=>(other)
  #     time_stamp <=> other.time_stamp
  #   end
  #
  #   def orig_path
  #     ret = path.dup
  #     ret.insert ret.rindex('.'), ".#{time_stamp}"
  #   end
  #
  # end

end