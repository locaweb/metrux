module Metrux
  module Commands
    class Base
      include Loggable

      HOST = Socket.gethostname.freeze
      DEFAULT_TAGS = { hostname: HOST }.freeze

      def initialize(config, connection)
        @config = config
        @app_name = config.app_name
        @connection = connection
        @logger = config.logger
      end

      protected

      attr_reader :app_name, :connection, :logger, :config

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
          tags: DEFAULT_TAGS.merge(app_name: app_name, uniq: uniq),
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
