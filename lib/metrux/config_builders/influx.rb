module Metrux
  module ConfigBuilders
    class Influx
      DEFAULT_TIME_PRECISION = 'ns'.freeze
      DEFAULT_ASYNC = true

      def initialize(yaml)
        @yaml = yaml
      end

      def build
        defaults.deep_merge(
          config_from_yaml.deep_merge(config_from_env_var)
        ).freeze
      end

      private

      attr_reader :yaml

      def config_from_env_var
        fetch_from(ENV, 'METRUX_INFLUX_'.freeze)
      end

      def config_from_yaml
        fetch_from(yaml, 'influx_'.freeze)
      end

      def fetch_from(object, prefix)
        object.each_with_object({}) do |(config_key, value), acc|
          if config_key.start_with?(prefix)
            acc[config_key.gsub(/^#{prefix}/, '').to_s.downcase.to_sym] =
              cast_value(value)
          end
        end
      end

      def cast_value(value)
        return value.to_f if value.to_s.to_f.to_s == value.to_s
        return value.to_i if value.to_s.to_i.to_s == value.to_s

        value
      rescue
        value
      end

      def defaults
        { time_precision: DEFAULT_TIME_PRECISION, async: DEFAULT_ASYNC }
      end
    end
  end
end
