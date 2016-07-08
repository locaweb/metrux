module Metrux
  module Plugins
    class Gc < Base
      def call
        register('gc') do
          {
            count: count, major_count: major_count, minor_count: minor_count,
            total_allocated_objects: total_allocated_objects,
            heap_live: heap_live, heap_free: heap_free
          }
        end
      end

      private

      def count
        ::GC.count
      end

      def major_count
        gc_stats[:major_gc_count]
      end

      def minor_count
        gc_stats[:minor_gc_count]
      end

      def total_allocated_objects
        gc_stats[:total_allocated_objects] ||
          gc_stats[:total_allocated_object]
      end

      def heap_live
        gc_stats[:heap_live_slots] ||
          gc_stats[:heap_live_slot] ||
          gc_stats[:heap_live_num]
      end

      def heap_free
        gc_stats[:heap_free_slots] ||
          gc_stats[:heap_free_slot] ||
          gc_stats[:heap_free_num]
      end

      def gc_stats
        ::GC.stat
      end
    end
  end
end
