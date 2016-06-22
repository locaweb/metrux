module Metrux
  module Commands
    class NoticeError < Meter
      ERROR_METER_KEY = 'errors'.freeze

      def execute(error, payload = {})
        tags =
          payload
          .each_with_object({}) do |(k, v), with_string_values|
            with_string_values[k] = v.is_a?(String) ? v : v.inspect
          end
          .merge(
            error: error.class.to_s,
            message: error.message.truncate(100, separator: ' ')
          )

        super(ERROR_METER_KEY, tags: tags)
      end
    end
  end
end
