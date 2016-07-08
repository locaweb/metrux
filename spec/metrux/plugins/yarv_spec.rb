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

    let(:expected_result) do
      {
        global_method_state: global_method_state,
        global_constant_state: global_constant_state
      }
    end

    before do
      @result = nil

      allow(Metrux).to receive(:periodic_gauge) do |*_, &blk|
        @result = blk.call
      end

      allow(::RubyVM).to receive(:stat).and_return(vm_stat)
    end

    it do
      call

      expect(@result).to eq(expected_result)
    end

    it do
      expect(Metrux)
        .to receive(:periodic_gauge)
        .with('rubyvm', options)

      call
    end
  end
end
