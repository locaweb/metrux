module Metrux
  module Commands
    class PeriodicGauge < Gauge
      class Registry
        include Loggable

        def initialize(config)
          @mutex = Mutex.new
          @metrics = {}
          @logger = config.logger
        end

        def metrics
          mutex.synchronize { @metrics.dup }
        end

        def add(measurement, options = {}, &metric_block)
          tags = options.fetch(:tags, {})
          key = "#{measurement}/#{tags.to_query}".freeze

          log("Registering #{key}")

          mutex.synchronize do
            @metrics[key] = {
              measurement: measurement, metric: metric_block,
              options: options
            }
          end

          true
        end

        private

        attr_reader :mutex, :logger
      end
    end
  end
end
