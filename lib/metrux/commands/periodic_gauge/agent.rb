module Metrux
  module Commands
    class PeriodicGauge < Gauge
      class Agent
        include Loggable
        include Sleeper

        DEFAULT_INVERVAL = 60

        def initialize(command, registry, config)
          @command = command
          @registry = registry
          @interval = config.periodic_gauge_interval || DEFAULT_INVERVAL
          @logger = config.logger
          @thread = nil
        end

        def start
          return false if alive?

          log('Starting...', :info)
          @thread = Thread.new do
            loop do
              log("sleeping for #{interval}s...")
              wait(interval)

              metrics.each(&method(:execute_metric))
            end
          end

          true
        end

        def stop
          log('Stopping...', :info)
          @thread.kill if @thread
          @thread = nil
        end

        def alive?
          @thread && @thread.alive?
        end

        private

        attr_reader :command, :interval, :registry

        def metrics
          registry.metrics
        end

        def execute_metric(key, params)
          log("Executing #{key}...", :info)

          command.gauge(
            params.fetch(:measurement), params.fetch(:options),
            &params.fetch(:metric)
          )
        rescue => e
          log(
            "ERROR #{key}: #{e.class}: #{e.message} #{e.backtrace.take(2)}",
            :error
          )
        end
      end
    end
  end
end
