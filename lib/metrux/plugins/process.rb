module Metrux
  module Plugins
    class Process < Base
      def initialize(*)
        super
        @pid = ::Process.pid
        @kernel_page_size = fetch_pagesize
        @statm_path = "/proc/#{pid}/statm".freeze
        @statm_found = ::File.exist?(statm_path)
      end

      def call
        register('Process#rss') { rss }
      end

      private

      attr_reader(:pid, :kernel_page_size, :statm_path, :statm_found)

      def rss
        case ::RbConfig::CONFIG['host_os']
        when /darwin|mac os/
          default_rss
        when /linux/
          linux_rss
        else
          0
        end
      rescue
        0
      end

      def linux_rss
        statm_found ? (fetch_statm_rss * kernel_page_size) / 1_024 : default_rss
      end

      def default_rss
        exec("ps -o rss= -p #{pid}").chomp.to_i
      end

      def fetch_statm_rss
        ::File.read(statm_path).split(' ')[1].to_i
      end

      def fetch_pagesize
        exec('getconf PAGESIZE').chomp.to_i
      rescue
        4_096
      end

      def exec(cmd)
        ::Kernel.public_send(:`, cmd)
      end
    end
  end
end
