module Gluey::UrlHelper

  attr_accessor :base_url

  def asset_url(material, path)
    "#{base_url}/#{material}/#{real_path material, path}"
  end

end