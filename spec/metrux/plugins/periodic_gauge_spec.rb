describe Metrux::Plugins::PeriodicGauge do
  subject(:plugin) { described_class.new(config, options) }

  let(:config) { build(:configuration) }
  let(:options) { { some: :options } }

  describe '#call' do
    subject(:call) { plugin.call }

    let(:key) { 'a-gauge-key' }
    let(:data) { { finished: 1, unfinished: 0 } }

    before do
      allow(Metrux).to receive(:periodic_gauge)
      allow(plugin).to receive(:key).and_return(key)
      allow(plugin).to receive(:data).and_return(data)
    end

    it do
      expect(Metrux)
        .to receive(:periodic_gauge)
        .with(key, options, result: data)

      call
    end
  end

  describe '#key' do
    subject(:key) { plugin.key }

    it do
      expect { key }
        .to raise_error(NotImplementedError, 'This is a base plugin')
    end
  end

  describe '#data' do
    subject(:data) { plugin.data }

    it do
      expect { data }
        .to raise_error(NotImplementedError, 'This is a base plugin')
    end
  end
end
