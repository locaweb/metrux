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

root = File.expand_path('../../', __FILE__)
Dir[File.join(root, 'spec/support/**/*.rb')].each { |f| require f }

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
  end
end
