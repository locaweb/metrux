module Metrux
  module Commands
    class Base
      extend Forwardable
      include Loggable

      DEFAULT_TAGS = {
        hostname: Metrux::HOST, program_name: Metrux::PROGRAM_NAME
      }.freeze

      def initialize(config, connection)
        @config = config
        @connection = connection
        @logger = config.logger
      end

      protected

      attr_reader :connection, :logger, :config

      def_delegators :config, :app_name, :env

      def write(measurement, data, options = {})
        precision = options[:precision].presence
        retention = options[:retention].presence

        log("Writing #{measurement}")

        connection.write_point(
          measurement, default_data.deep_merge(data), precision, retention
        )

        true
      end

      def format_data(value, params)
        values = value.is_a?(Hash) ? value : { value: value }
        { values: values, tags: params.fetch(:tags, {}) }
      end

      def format_write_options(params)
        params.select { |k, _| [:precision, :retention].include?(k) }
      end

      private

      def default_data
        {
          tags: DEFAULT_TAGS.merge(
            app_name: app_name, uniq: uniq, env: env
          ),
          timestamp: Time.now.utc.to_i
        }
      end

      # https://docs.influxdata.com/influxdb/v0.13/troubleshooting/frequently_encountered_issues/#writing-duplicate-points
      def uniq
        SecureRandom.hex(4)
      end
    end
  end
end
