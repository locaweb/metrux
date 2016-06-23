module Metrux
  module Commands
    class PeriodicGauge < Gauge
      class Reporter
        extend Forwardable

        def initialize(command, registry, config)
          @agent = Agent.new(command, registry, config)
          @supervisor = Supervisor.new(agent, config)
          @config = config
        end

        def start
          return false unless config.active?

          agent.start
          supervisor.start

          true
        end

        def stop
          supervisor.stop
          agent.stop
        end

        private

        attr_reader :agent, :supervisor, :config
      end
    end
  end
end
