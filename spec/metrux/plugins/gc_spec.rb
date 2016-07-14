describe Metrux::Plugins::Gc do
  subject(:plugin) { described_class.new(config, options) }

  let(:config) { build(:configuration) }
  let(:options) { { tags: { some: 'tag' } } }

  describe '.ancestors' do
    subject(:ancestors) { described_class.ancestors }

    it { is_expected.to include(Metrux::Plugins::PeriodicGauge) }
  end

  describe '#data' do
    subject(:data) { plugin.data }

    let(:gc_stat) do
      {
        major_gc_count: major_gc_count, minor_gc_count: minor_gc_count,
        total_allocated_objects: total_allocated_objects,
        heap_live_slots: heap_live, heap_free_slots: heap_free
      }
    end

    let(:gc_count) { 42 }
    let(:major_gc_count) { 43 }
    let(:minor_gc_count) { 44 }
    let(:total_allocated_objects) { 45 }
    let(:heap_live) { 46 }
    let(:heap_free) { 47 }

    let(:expected_data) do
      {
        count: gc_count, major_count: major_gc_count,
        minor_count: minor_gc_count,
        total_allocated_objects: total_allocated_objects,
        heap_live: heap_live, heap_free: heap_free
      }
    end

    before do
      allow(::GC).to receive(:stat).and_return(gc_stat)
      allow(::GC).to receive(:count).and_return(gc_count)
    end

    it { is_expected.to eq(expected_data) }
  end

  describe '#key' do
    subject(:key) { plugin.key }

    it { is_expected.to eq('gc') }
  end
end
