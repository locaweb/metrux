describe Metrux::Commands::Gauge, type: :command do
  subject(:command) { described_class.new(config, connection) }

  let(:config) { Metrux::Configuration.new }
  let(:connection) do
    instance_double(Metrux::Connections::InfluxDb, write_point: nil)
  end

  describe '#execute' do
    subject(:execute) { command.execute(key) { result } }

    let(:key) { 'my-key' }
    let(:result) { 42 }
    let(:prefix) { config.prefix }

    let(:expected_key) { "#{prefix}/gauges/#{key}" }
    let(:expected_tags) { default_tags }
    let(:expected_data) do
      {
        values: { value: result }, tags: expected_tags,
        timestamp: now_timestamp
      }
    end

    it { is_expected.to be(result) }

    it do
      expect(connection)
        .to receive(:write_point)
        .with(expected_key, expected_data, nil, nil)

      execute
    end

    context 'when the result was previously executed' do
      subject(:execute) { command.execute(key, result: result) }

      it { is_expected.to be(result) }

      it do
        expect(connection)
          .to receive(:write_point)
          .with(expected_key, expected_data, nil, nil)

        execute
      end
    end

    context 'when a block and result were not given' do
      subject(:execute) { command.execute(key) }

      it { expect { execute }.to raise_error(KeyError) }
    end

    context 'when the data is a Hash' do
      let(:result) { { multi: :value } }
      let(:expected_data) do
        { values: result, tags: expected_tags, timestamp: now_timestamp }
      end

      it { is_expected.to be(result) }

      it do
        expect(connection)
          .to receive(:write_point)
          .with(expected_key, expected_data, nil, nil)

        execute
      end
    end

    context 'when some options are passed' do
      subject(:execute) { command.execute(key, options) { result } }

      let(:tags) { { some: 'tag' } }
      let(:options) { { precision: 's', retention: '1h.cpu', tags: tags } }

      let(:expected_tags) { default_tags.merge(tags) }

      it { is_expected.to be(result) }

      it do
        expect(connection)
          .to receive(:write_point)
          .with(expected_key, expected_data, 's', '1h.cpu')

        execute
      end
    end
  end
end
