require 'metrux/version'
require 'metrux/loggable'

module Metrux
  class << self
    attr_reader :logger
  end
end
