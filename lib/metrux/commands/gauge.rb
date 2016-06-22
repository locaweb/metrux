module Metrux
  module Commands
    class Gauge < Base
      GAUGE_MEASUREMENT_PREFIX_KEY = 'gauges/'.freeze

      def execute(key, params = {})
        block_given? ? gauge(key, params) { yield } : gauge(key, params)
      end

      def gauge(key, params = {})
        key = "#{GAUGE_MEASUREMENT_PREFIX_KEY}#{key}"

        result = block_given? ? yield : params.fetch(:result)

        write(key, format_data(result, params), format_write_options(params))

        result
      end
    end
  end
end
