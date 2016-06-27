module Metrux
  module Plugins
    class Base
      def initialize(config, options = {})
        @config = config
        @options = options
      end

      protected

      attr_reader :config, :options

      def prefix
        prefix = options[:prefix]
        prefix.presence && "#{prefix}/"
      end

      def register(key, &block)
        Metrux.periodic_gauge("#{prefix}#{key}", options, &block)
      end
    end
  end
end
