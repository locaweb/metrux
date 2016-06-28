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

    before do
      @result = nil

      allow(Metrux).to receive(:periodic_gauge)
      allow(::GC).to receive(:stat).and_return(gc_stat)
    end

    it do
      allow(Metrux)
        .to receive(:periodic_gauge)
        .with('GC#count', anything) { |*_, &blk| @result = blk.call }

      allow(::GC).to receive(:count).and_return(gc_count)

      call

      expect(@result).to be(gc_count)
    end

    it do
      allow(Metrux)
        .to receive(:periodic_gauge)
        .with('GC#major_gc_count', anything) { |*_, &blk| @result = blk.call }

      call

      expect(@result).to be(major_gc_count)
    end

    it do
      allow(Metrux)
        .to receive(:periodic_gauge)
        .with('GC#minor_gc_count', anything) { |*_, &blk| @result = blk.call }

      call

      expect(@result).to be(minor_gc_count)
    end

    it do
      allow(Metrux)
        .to receive(:periodic_gauge)
        .with('GC#total_allocated_object', anything) do |*_, &blk|
        @result = blk.call
      end

      call

      expect(@result).to be(total_allocated_objects)
    end

    it do
      allow(Metrux)
        .to receive(:periodic_gauge)
        .with('GC#heap_live', anything) do |*_, &blk|
        @result = blk.call
      end

      call

      expect(@result).to be(heap_live)
    end

    it do
      allow(Metrux)
        .to receive(:periodic_gauge)
        .with('GC#heap_free', anything) do |*_, &blk|
        @result = blk.call
      end

      call

      expect(@result).to be(heap_free)
    end

    %w(
      GC#count GC#major_gc_count GC#minor_gc_count GC#total_allocated_object
      GC#heap_live GC#heap_free
    ).each do |key|
      context "for key #{key}" do
        let(:expected_key) { key }

        before { allow(Metrux).to receive(:periodic_gauge) }

        it do
          expect(Metrux)
            .to receive(:periodic_gauge)
            .with(expected_key, options)

          call
        end
      end
    end
  end
end
