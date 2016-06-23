module Metrux
  module Commands
    class PeriodicGauge < Gauge
      class Supervisor
        include Loggable
        include Sleeper

        INTERVAL_CHECK = 10

        def initialize(agent, config)
          @agent = agent
          @logger = config.logger
          @thread = nil
        end

        def start
          unless alive?
            log('Starting...', :info)
            @thread = Thread.new { loop { check } }

            return true
          end
          false
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

        attr_reader :agent

        def check
          wait(INTERVAL_CHECK)

          unless agent.alive?
            log('Agent is dead. Restarting...', :info)
            agent.start
          end
        rescue => e
          log("ERROR: #{e.class}: #{e.message}", :error)
        end
      end
    end
  end
end
