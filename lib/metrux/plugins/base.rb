module Metrux
  module Plugins
    class Base
      def initialize(config, options = {})
        @config = config
        @options = options
      end

      protected

      attr_reader :config, :options

      def register(key, &block)
        Metrux.periodic_gauge(key, options, &block)
      end
    end
  end
end
