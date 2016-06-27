module Metrux
  module Commands
    class PeriodicGauge < Gauge
      require_relative 'periodic_gauge/registry'
      require_relative 'periodic_gauge/agent'
      require_relative 'periodic_gauge/supervisor'
      require_relative 'periodic_gauge/reporter'

      attr_reader :registry, :reporter

      def initialize(config, connection)
        super
        @registry = Registry.new(config)
        @reporter = Reporter.new(self, registry, config)
      end

      def execute(key, params = {})
        registry.add(key, params) { yield }
        reporter.start

        true
      end
    end
  end
end
