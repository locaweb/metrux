module Metrux
  module Plugins
    class Yarv < Base
      def call
        register('RubyVM#global_method_state') do
          ::RubyVM.stat[:global_method_state]
        end

        register('RubyVM#global_constant_state') do
          ::RubyVM.stat[:global_constant_state]
        end
      end
    end
  end
end
