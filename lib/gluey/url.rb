module Gluey::Url

  attr_accessor :base_url

  def asset_url(material, path, mark=false)
    "#{base_url}/#{material}/#{real_path material, path, mark}"
  end

end