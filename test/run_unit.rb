Bundler.require(:default, 'test') if defined?(Bundler)

require_relative '../lib/gluey'
require 'minitest/autorun'

TESTS_PATH = File.expand_path '..', __FILE__

Dir["#{File.join TESTS_PATH, 'unit'}/**/*.rb"].each{|f| require f}