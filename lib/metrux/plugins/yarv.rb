module Metrux
  module Plugins
    class Yarv < Base
      def call
        register('rubyvm') do
          {
            global_method_state: global_method_state,
            global_constant_state: global_constant_state
          }
        end
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
