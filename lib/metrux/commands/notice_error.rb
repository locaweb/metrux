module Metrux
  module Commands
    class NoticeError < Base
      ERROR_METER_KEY = 'meters/errors'.freeze

      def execute(error, payload = {})
        value = build_value(error)
        options = build_options(error, payload)

        write(ERROR_METER_KEY, format_data(value, options))
      end

      private

      def build_value(error)
        { message: error.message.truncate(100, separator: ' '), value: 1 }
      end

      def build_options(error, payload)
        {}.tap do |options|
          options[:tags] = fetch_tags(error, payload)

          if payload[:timestamp].present?
            options[:timestamp] = payload[:timestamp]
          end
        end
      end

      def fetch_tags(error, payload)
        payload
          .reject { |(k, _)| k.to_s == 'timestamp' }
          .each_with_object({}) do |(k, v), with_string_values|
          with_string_values[k] = v.is_a?(String) ? v : v.inspect
        end.merge(error: error.class.to_s)
      end
    end
  end
end
