require 'uglifier'

module Gluey::Glues
  class JsScript < Script

    def self.set_uglifier_options(**opts)
      @uglifier_options = {copyright: :none}.merge! opts
    end

    def self.uglifier
      @uglifier ||= ::Uglifier.new(@uglifier_options || set_uglifier_options)
    end

    def process(base_file, deps)
      JsScript.uglifier.compile super
    end

  end
end