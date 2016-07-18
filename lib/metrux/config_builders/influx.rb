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
        string_value = value.to_s

        unless (numeric_value = numeric_value(string_value)).nil?
          return numeric_value
        end

        unless (boolean_value = boolean_value(string_value)).nil?
          return boolean_value
        end

        value
      end

      def numeric_value(value)
        return value.to_f if value.to_f.to_s == value
        return value.to_i if value.to_i.to_s == value

        nil
      end

      def boolean_value(value)
        return true if value == true || value =~ /^(true)$/i
        return false if value == false || value =~ /^(false)$/i

        nil
      end

      def defaults
        { time_precision: DEFAULT_TIME_PRECISION, async: DEFAULT_ASYNC }
      end
    end
  end
end
