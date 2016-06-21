module Metrux
  module ConfigBuilders
    ConfigurationError = Class.new(RuntimeError)
  end
end

require_relative 'config_builders/yaml'
