module Metrux
  module ConfigBuilders
    class Influx
      HOST_KEY = 'METRUX_INFLUX_HOST'.freeze
      PORT_KEY = 'METRUX_INFLUX_PORT'.freeze
      DATABASE_KEY = 'METRUX_INFLUX_DATABASE'.freeze
      USERNAME_KEY = 'METRUX_INFLUX_USERNAME'.freeze
      PASSWORD_KEY = 'METRUX_INFLUX_PASSWORD'.freeze
      ASYNC_KEY = 'METRUX_INFLUX_ASYNC'.freeze
      DEFAULT_TIME_PRECISION = 'ns'.freeze

      ConfigNotFoundError = Class.new(ConfigurationError)

      def initialize(yaml)
        @yaml = yaml
      end

      def build
        {
          host: host, port: port, database: database, username: username,
          password: password, async: async,
          time_precision: DEFAULT_TIME_PRECISION
        }.freeze
      rescue KeyError => e
        raise(ConfigNotFoundError, "#{e.class}: #{e.message}")
      end

      private

      attr_reader :yaml

      %w(host port database username password async).each do |reader|
        define_method(reader) do
          ENV[self.class.const_get("#{reader.upcase}_KEY")] ||
            yaml.fetch("influx_#{reader}".to_sym)
        end
      end
    end
  end
end
