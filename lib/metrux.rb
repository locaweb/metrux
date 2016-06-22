require 'influxdb'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/object/blank'
require 'yaml'
require 'metrux/version'
require 'metrux/loggable'
require 'metrux/configuration'
require 'metrux/config_builders'
require 'metrux/connections'

module Metrux
  class << self
    attr_reader :logger
  end
end
