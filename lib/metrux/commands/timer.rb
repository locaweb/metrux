module Metrux
  module Commands
    class Timer < Base
      TIMER_MEASUREMENT_PREFIX_KEY = 'timers/'.freeze

      def execute(key, params = {})
        key = "#{TIMER_MEASUREMENT_PREFIX_KEY}#{key}"

        result, duration = if block_given?
                             calculate_duration { yield }
                           else
                             [nil, params.fetch(:duration)]
                           end

        write(key, format_data(duration, params), format_write_options(params))

        result
      end

      private

      def calculate_duration
        started_at = Time.now
        result = yield
        duration = ((Time.now - started_at) * 1_000).ceil
        [result, duration]
      end
    end
  end
end
