module Metrux
  module Plugins
    class Thread < PeriodicGauge
      def data
        { count: ::Thread.list.count }
      end

      def key
        'thread'.freeze
      end
    end
  end
end
