describe Metrux::Commands::NoticeError, type: :command do
  subject(:command) { described_class.new(config, connection) }

  let(:config) { build(:configuration) }
  let(:connection) do
    instance_double(Metrux::Connections::InfluxDb, write_point: nil)
  end

  describe '#execute' do
    subject(:execute) { command.execute(error) }

    let(:error) { RuntimeError.new(error_message) }
    let(:error_message) { 'something went wrong' }
    let(:error_class) { error.class.to_s }
    let(:error_tags) { { error: error_class, message: error_message } }
    let(:prefix) { config.prefix }

    let(:expected_key) { "#{prefix}/meters/errors" }
    let(:expected_tags) { default_tags.merge(error_tags) }
    let(:expected_data) do
      { values: { value: 1 }, tags: expected_tags, timestamp: now_timestamp }
    end

    it { is_expected.to be(true) }

    it do
      expect(connection)
        .to receive(:write_point)
        .with(expected_key, expected_data, nil, nil)

      execute
    end

    context 'when a payload is passed' do
      subject(:execute) { command.execute(error, payload) }

      let(:payload) { tags }
      let(:tags) do
        { string: 'value', klass: Object.new, hash: { key: :value } }
      end

      let(:tags_on_string_values) do
        tags.transform_values { |v| v.is_a?(String) ? v : v.inspect }
      end

      let(:expected_tags) do
        default_tags.merge(error_tags).merge(tags_on_string_values)
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
