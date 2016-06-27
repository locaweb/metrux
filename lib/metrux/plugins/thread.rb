module Metrux
  module Plugins
    class Thread < Base
      def call
        register('Thread.list.count') { ::Thread.list.count }
      end
    end
  end
end
