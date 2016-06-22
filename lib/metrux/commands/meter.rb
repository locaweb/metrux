module Metrux
  module Commands
    class Meter < Base
      METER_MEASUREMENT_PREFIX_KEY = 'meters/'.freeze

      def execute(key, params = {})
        key = "#{METER_MEASUREMENT_PREFIX_KEY}#{key}"

        value = params.fetch(:value, 1).to_i

        write(key, format_data(value, params), format_write_options(params))
      end
    end
  end
end
