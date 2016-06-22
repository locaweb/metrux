module Metrux
  module Connections
    class Null
      include Metrux::Loggable

      def initialize(config)
        @logger = config.logger
      end

      (InfluxDb.public_instance_methods - public_instance_methods)
        .each do |method|
        define_method(method) do |*args, &block|
          log("Calling #{method} with #{args}. Block given? #{block.present?}")
          self
        end
      end
    end
  end
end
