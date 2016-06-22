require 'influxdb'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/object/blank'
require 'securerandom'
require 'yaml'
require 'metrux/version'
require 'metrux/loggable'
require 'metrux/configuration'
require 'metrux/config_builders'
require 'metrux/connections'
require 'metrux/commands'

module Metrux
  class << self
    attr_reader :logger
  end
end
