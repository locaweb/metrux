module Metrux
  class Configuration
    DEFAULT_ENVIRONMENT = 'development'.freeze

    def initialize(
      config_path = File.join(File.expand_path('.'), 'config', 'metrux.yml')
    )
      @config_path = config_path
    end

    def env
      @env ||= ENV['RAILS_ENV'] || ENV['RACK_ENV'] || DEFAULT_ENVIRONMENT
    end

    def app_name
      @app_name ||= commons[:app_name]
    end

    def prefix
      @prefix ||= commons[:prefix]
    end

    def active?
      @active ||= commons[:active]
    end

    def influx
      @influx ||= ConfigBuilders::Influx.new(yaml).build
    end

    def periodic_gauge_interval
      @periodic_gauge_interval ||=
        ConfigBuilders::PeriodicGauge.new(yaml).build
    end

    def logger
      @logger ||= ConfigBuilders::Logger.new(yaml).build
    end

    def yaml
      @yaml ||= ConfigBuilders::Yaml.new(config_path, env).build
    end

    def commons
      @commons ||= ConfigBuilders::Common.new(yaml).build
    end

    private

    attr_reader :config_path
  end
end
