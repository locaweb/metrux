describe Metrux::Plugins::Gc do
  subject(:plugin) { described_class.new(config, options) }

  let(:config) { Metrux::Configuration.new }
  let(:options) { { tags: { some: 'tag' } } }

  describe '#call' do
    subject(:call) { plugin.call }

    let(:gc_stat) do
      {
        major_gc_count: major_gc_count, minor_gc_count: minor_gc_count,
        total_allocated_objects: total_allocated_objects,
        heap_live_slots: heap_live, heap_free_slots: heap_free
      }
    end

    let(:gc_count) { 42 }
    let(:major_gc_count) { rand(1_000_000) }
    let(:minor_gc_count) { rand(1_000_000) }
    let(:total_allocated_objects) { rand(1_000_000) }
    let(:heap_live) { rand(1_000_000) }
    let(:heap_free) { rand(1_000_000) }

    let(:expected_result) do
      {
        count: gc_count, major_count: major_gc_count,
        minor_count: minor_gc_count,
        total_allocated_objects: total_allocated_objects,
        heap_live: heap_live, heap_free: heap_free
      }
    end

    before do
      @result = nil

      allow(Metrux).to receive(:periodic_gauge) do |*_, &blk|
        @result = blk.call

      end
      allow(::GC).to receive(:stat).and_return(gc_stat)
      allow(::GC).to receive(:count).and_return(gc_count)
    end

    it do
      call

      expect(@result).to eq(expected_result)
    end

    it do
      expect(Metrux)
        .to receive(:periodic_gauge)
        .with('gc', options)

      call
    end
  end
end
