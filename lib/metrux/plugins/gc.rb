module Metrux
  module Plugins
    class Gc < Base
      def call
        register_gc_count
        register_allocated_objects
        register_heap_live
        register_heap_free
      end

      private

      def register_gc_count
        register('GC#count') { ::GC.count }
        register('GC#major_gc_count') { ::GC.stat[:major_gc_count] }
        register('GC#minor_gc_count') { ::GC.stat[:minor_gc_count] }
      end

      def register_allocated_objects
        register('GC#total_allocated_object') do
          gc_stats = ::GC.stat
          gc_stats[:total_allocated_objects] ||
            gc_stats[:total_allocated_object]
        end
      end

      def register_heap_live
        register('GC#heap_live') do
          gc_stats = ::GC.stat
          gc_stats[:heap_live_slots] ||
            gc_stats[:heap_live_slot] ||
            gc_stats[:heap_live_num]
        end
      end

      def register_heap_free
        register('GC#heap_free') do
          gc_stats = ::GC.stat
          gc_stats[:heap_free_slots] ||
            gc_stats[:heap_free_slot] ||
            gc_stats[:heap_free_num]
        end
      end
    end
  end
end
