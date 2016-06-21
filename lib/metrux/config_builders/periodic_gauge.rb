module Metrux
  module ConfigBuilders
    class PeriodicGauge
      INTERVAL_KEY = 'METRUX_PERIODIC_GAUGE_INTERVAL'.freeze

      def initialize(yaml)
        @yaml = yaml
      end

      def build
        interval = (ENV[INTERVAL_KEY] || yaml[:periodic_gauge_interval]).to_i

        (interval > 0 && interval).presence
      end

      private

      attr_reader :yaml
    end
  end
end
