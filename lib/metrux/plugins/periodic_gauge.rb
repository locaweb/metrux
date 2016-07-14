module Metrux
  module Plugins
    class PeriodicGauge
      def initialize(config, options = {})
        @config = config
        @options = options
      end

      def call
        Metrux.periodic_gauge(key, options, result: data)
      end

      def key
        not_implemented
      end

      def data
        not_implemented
      end

      protected

      attr_reader :config, :options

      private

      def not_implemented
        raise NotImplementedError, 'This is a base plugin'
      end
    end
  end
end
