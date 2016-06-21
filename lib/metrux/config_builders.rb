module Metrux
  module ConfigBuilders
    ConfigurationError = Class.new(RuntimeError)
  end
end

require_relative 'config_builders/yaml'
require_relative 'config_builders/common'
require_relative 'config_builders/periodic_gauge'
require_relative 'config_builders/influx'
require_relative 'config_builders/logger'
