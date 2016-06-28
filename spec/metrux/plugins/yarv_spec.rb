describe Metrux::Plugins::Yarv do
  subject(:plugin) { described_class.new(config, options) }

  let(:config) { Metrux::Configuration.new }
  let(:options) { { tags: { some: 'tag' } } }

  describe '#call' do
    subject(:call) { plugin.call }

    let(:vm_stat) do
      {
        global_method_state: global_method_state,
        global_constant_state: global_constant_state
      }
    end

    let(:global_method_state) { 42 }
    let(:global_constant_state) { 43 }

    before do
      @result = nil

      allow(Metrux).to receive(:periodic_gauge)
      allow(::RubyVM).to receive(:stat).and_return(vm_stat)
    end

    it do
      allow(Metrux)
        .to receive(:periodic_gauge)
        .with('RubyVM#global_method_state', anything) do |*_, &blk|
        @result = blk.call
      end

      call

      expect(@result).to be(global_method_state)
    end

    it do
      allow(Metrux)
        .to receive(:periodic_gauge)
        .with('RubyVM#global_constant_state', anything) do |*_, &blk|
        @result = blk.call
      end

      call

      expect(@result).to be(global_constant_state)
    end

    %w(RubyVM#global_method_state RubyVM#global_constant_state).each do |key|
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
