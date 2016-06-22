module Metrux
  module Connections
    class InfluxDb
      extend Forwardable

      def_delegator :client, :write_point

      def initialize(config)
        @client = ::InfluxDB::Client.new(config.influx)
      end

      private

      attr_reader :client
    end
  end
end
