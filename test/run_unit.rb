Bundler.require(:default, 'test') if defined?(Bundler)

require_relative '../lib/gluey'
require 'minitest/autorun'

PROJECT_PATH = File.expand_path '../..', __FILE__

Dir["#{File.join PROJECT_PATH, 'test', 'unit'}/**/*.rb"].each{|f| require f}