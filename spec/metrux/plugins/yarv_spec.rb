describe Metrux::Plugins::Yarv do
  subject(:plugin) { described_class.new(config, options) }

  let(:config) { build(:configuration) }
  let(:options) { { tags: { some: 'tag' } } }

  describe '.ancestors' do
    subject(:ancestors) { described_class.ancestors }

    it { is_expected.to include(Metrux::Plugins::PeriodicGauge) }
  end

  describe '#data' do
    subject(:data) { plugin.data }

    let(:expected_data)  do
      {
        global_method_state: global_method_state,
        global_constant_state: global_constant_state
      }
    end

    let(:vm_stat) do
      {
        global_method_state: global_method_state,
        global_constant_state: global_constant_state
      }
    end

    let(:global_method_state) { 42 }
    let(:global_constant_state) { 43 }

    before { allow(::RubyVM).to receive(:stat).and_return(vm_stat) }

    it { is_expected.to eq(expected_data) }
  end

  describe '#key' do
    subject(:key) { plugin.key }

    it { is_expected.to eq('rubyvm') }
  end
end
