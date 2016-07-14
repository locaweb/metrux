module Metrux
  module Plugins
    class Yarv < PeriodicGauge
      def data
        {
          global_method_state: global_method_state,
          global_constant_state: global_constant_state
        }
      end

      def key
        'rubyvm'.freeze
      end

      private

      def global_method_state
        ::RubyVM.stat[:global_method_state]
      end

      def global_constant_state
        ::RubyVM.stat[:global_constant_state]
      end
    end
  end
end
