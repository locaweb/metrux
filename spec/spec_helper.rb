ENV['RAILS_ENV'] ||= 'test'
ENV['METRUX_ACTIVE'] = 'true'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

if ENV['COVERAGE']
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start do
    add_filter '/vendor/'
    add_filter '/spec/'
  end
end

require 'pry'
require 'shoulda-matchers'
require 'metrux'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
  end
end
