module Metrux
  module Commands
    class Write < Base
      def execute(key, data, options = {})
        write(key, format_data(data, options), format_write_options(options))
      end
    end
  end
end
