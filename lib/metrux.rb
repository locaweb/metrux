require 'influxdb'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/filters'
require 'securerandom'
require 'erb'
require 'yaml'
require 'thread'
require 'metrux/version'
require 'metrux/constants'
require 'metrux/loggable'
require 'metrux/sleeper'
require 'metrux/client'
require 'metrux/configuration'
require 'metrux/config_builders'
require 'metrux/connections'
require 'metrux/commands'
require 'metrux/plugins'
require 'metrux/plugin_register'

module Metrux
  class << self
    extend Forwardable

    attr_reader :configured

    alias configured? configured

    def_delegators(:client, *Client::AVAILABLE_COMMANDS)
    def_delegator :config, :logger
    def_delegator :plugin_register, :register
    def_delegator :plugin_register, :plugins

    def setup(config = nil)
      @config = config || Configuration.new
      @client = Client.new(@config)
      @plugin_register = PluginRegister.new(@config)
      @configured = true
    end

    def client
      lazy_setup { @client }
    end

    def config
      lazy_setup { @config }
    end

    def plugin_register
      lazy_setup { @plugin_register }
    end

    private

    def lazy_setup
      setup unless configured?
      yield
    end
  end
end
