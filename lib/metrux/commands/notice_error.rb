module Metrux
  module Commands
    class NoticeError < Base
      ERROR_METER_KEY = 'meters/errors'.freeze

      def execute(error, options = {})
        write(ERROR_METER_KEY, fetch_data(error, options))
      end

      private

      def fetch_tags(error, options)
        options.each_with_object({}) do |(k, v), with_string_values|
          with_string_values[k] = v.is_a?(String) ? v : v.inspect
        end.merge(error: error.class.to_s)
      end

      def fetch_data(error, options)
        format_data(
          { message: error.message.truncate(100, separator: ' '), value: 1 },
          { tags: fetch_tags(error, options) }
        )
      end
    end
  end
end
