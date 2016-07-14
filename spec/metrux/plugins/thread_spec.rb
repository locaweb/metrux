describe Metrux::Plugins::Thread do
  subject(:plugin) { described_class.new(config, options) }

  let(:config) { build(:configuration) }
  let(:options) { { tags: { some: 'tag' } } }

  describe '.ancestors' do
    subject(:ancestors) { described_class.ancestors }

    it { is_expected.to include(Metrux::Plugins::PeriodicGauge) }
  end

  describe '#data' do
    subject(:data) { plugin.data }

    let(:expected_data) { { count: thread_list.count } }
    let(:thread_list) { 42.times.map(&:to_i) }

    before { allow(::Thread).to receive(:list).and_return(thread_list) }

    it { is_expected.to eq(expected_data) }
  end

  describe '#key' do
    subject(:key) { plugin.key }

    it { is_expected.to eq('thread') }
  end
end
