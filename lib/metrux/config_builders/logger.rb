module Metrux
  module ConfigBuilders
    class Logger
      LOG_FILE_KEY = 'METRUX_LOG_FILE'.freeze
      LOG_LEVEL_KEY = 'METRUX_LOG_LEVEL'.freeze

      DEFAULT_LOG_PATH = STDOUT
      DEFAULT_LOG_LEVEL = :info

      def initialize(yaml)
        @yaml = yaml
      end

      def build
        ::Logger.new(log_file).tap do |logger|
          logger.level = log_level
          logger.formatter = ::Logger::Formatter.new
        end
      rescue => e
        Kernel.warn(
          '[WARNING] Cound\'t configure Metrux\'s logger. '\
          "#{e.class}: #{e.message}"
        )
        nil
      end

      private

      attr_reader :yaml

      def log_file
        from_config = (ENV[LOG_FILE_KEY] || yaml[:log_file]).presence

        return DEFAULT_LOG_PATH if from_config.blank?

        from_config == 'STDOUT'.freeze ? STDOUT : from_config
      end

      def log_level
        ::Logger.const_get(
          (
            ENV[LOG_LEVEL_KEY] || yaml[:log_level] || DEFAULT_LOG_LEVEL
          ).to_s.upcase
        )
      end
    end
  end
end
