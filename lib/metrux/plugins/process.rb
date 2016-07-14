module Metrux
  module Plugins
    class Process < PeriodicGauge
      def initialize(*)
        super
        @pid = ::Process.pid
      end

      def data
        { rss: rss }
      end

      def key
        'process'.freeze
      end

      private

      attr_reader :pid

      def rss
        case ::RbConfig::CONFIG['host_os']
        when /darwin|mac os/
          default_rss
        when /linux/
          linux_rss
        else
          0
        end
      end

      def linux_rss
        statm? ? (fetch_statm_rss * kernel_page_size) / 1_024 : default_rss
      rescue
        0
      end

      def default_rss
        exec("ps -o rss= -p #{pid}").chomp.to_i
      rescue
        0
      end

      def kernel_page_size
        @kernel_page_size ||= fetch_pagesize
      end

      def statm_path
        @statm_path ||= "/proc/#{pid}/statm".freeze
      end

      def statm?
        @statm_found ||= ::File.exist?(statm_path)
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
