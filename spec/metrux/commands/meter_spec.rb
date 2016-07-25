describe Metrux::Commands::Meter, type: :command do
  subject(:command) { described_class.new(config, connection) }

  let(:config) { build(:configuration) }
  let(:connection) do
    instance_double(Metrux::Connections::InfluxDb, write_point: nil)
  end

  describe '#execute' do
    subject(:execute) { command.execute(key) }

    let(:key) { 'my-key' }
    let(:data) { 1 }
    let(:prefix) { config.prefix }

    let(:expected_key) { "#{prefix}/meters/#{key}" }
    let(:expected_tags) { default_tags }
    let(:expected_data) do
      {
        values: { value: data }, tags: expected_tags, timestamp: now_timestamp
      }
    end

    it { is_expected.to be(true) }

    it do
      expect(connection)
        .to receive(:write_point)
        .with(expected_key, expected_data, nil, nil)

      execute
    end

    context 'when the value is different than 1' do
      subject(:execute) { command.execute(key, value: data) }

      let(:data) { 42 }

      it { is_expected.to be(true) }

      it do
        expect(connection)
          .to receive(:write_point)
          .with(expected_key, expected_data, nil, nil)

        execute
      end
    end

    context 'when some options are passed' do
      subject(:execute) { command.execute(key, options) }

      let(:tags) { { some: 'tag' } }
      let(:options) { { precision: 's', retention: '1h.cpu', tags: tags } }

      let(:expected_tags) { default_tags.merge(tags) }

      it { is_expected.to be(true) }

      it do
        expect(connection)
          .to receive(:write_point)
          .with(expected_key, expected_data, 's', '1h.cpu')

        execute
      end

      context 'and a timestamp is passed' do
        let(:options) { { timestamp: timestamp } }
        let(:timestamp) { Time.new(2016, 1, 1).to_i }

        let(:expected_tags) { default_tags }

        let(:expected_data) do
          {
            values: { value: 1 }, tags: expected_tags,
            timestamp: timestamp
          }
        end

        it { is_expected.to be(true) }

        it do
          expect(connection)
            .to receive(:write_point)
            .with(expected_key, expected_data, nil, nil)

          execute
        end
      end
    end
  end
end
