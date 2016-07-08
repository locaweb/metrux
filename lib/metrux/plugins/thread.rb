module Metrux
  module Plugins
    class Thread < Base
      def call
        register('thread') { { count: ::Thread.list.count } }
      end
    end
  end
end
