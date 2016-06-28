module Metrux
  class Configuration
    DEFAULT_ENVIRONMENT = 'development'.freeze

    attr_reader(
      :env, :periodic_gauge_interval, :app_name, :prefix, :logger, :active,
      :influx
    )

    alias active? active

    def initialize(
      config_path = File.join(File.expand_path('.'), 'config', 'metrux.yml')
    )
      @config_path = config_path
      setup
      freeze
    end

    private

    attr_reader :yaml, :config_path

    def setup
      @env = fetch_env.freeze
      @yaml = fetch_yaml
      @app_name = fetch_app_name
      @prefix = fetch_prefix
      @active = fetch_active
      @periodic_gauge_interval = fetch_periodic_gauge_interval
      @influx = fetch_influx
      @logger = fetch_logger
    end

    def fetch_env
      ENV['RAILS_ENV'] || ENV['RACK_ENV'] || DEFAULT_ENVIRONMENT
    end

    def fetch_yaml
      ConfigBuilders::Yaml.new(config_path, env).build
    end

    def commons
      @commons ||= ConfigBuilders::Common.new(yaml).build
    end

    def fetch_app_name
      commons[:app_name].freeze
    end

    def fetch_prefix
      commons[:prefix].freeze
    end

    def fetch_active
      commons[:active]
    end

    def fetch_influx
      ConfigBuilders::Influx.new(yaml).build
    end

    def fetch_periodic_gauge_interval
      ConfigBuilders::PeriodicGauge.new(yaml).build
    end

    def fetch_logger
      ConfigBuilders::Logger.new(yaml).build
    end
  end
end
