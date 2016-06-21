require 'active_support/core_ext/hash'
require 'yaml'
require 'metrux/version'
require 'metrux/loggable'
require 'metrux/configuration'
require 'metrux/config_builders'

module Metrux
  class << self
    attr_reader :logger
  end
end
