describe Metrux::Connections::InfluxDb do
  subject(:connection) { described_class.new(config) }

  let(:config) { Metrux::Configuration.new }
  let(:influx_config) { config.influx }

  it { is_expected.to be_truthy }

  it do
    expect(InfluxDB::Client).to receive(:new)
      .with(influx_config)
      .and_call_original

    connection
  end

  it do
    should delegate_method(:write_point).to(:client)
  end

  describe '#write_point' do
    subject(:write_point) do
      connection.write_point(key, data, precision, retention)
    end

    let(:key) { 'a-measure-key' }
    let(:data) { { values: { value: 1 }, tags: { some: 'tag' } } }
    let(:precision) { 's' }
    let(:retention) { '1h.cpu' }

    let(:client) { instance_double(InfluxDB::Client, write_point: result) }
    let(:result) { instance_double(Net::HTTPNoContent) }

    before do
      allow(InfluxDB::Client).to receive(:new).and_return(client)
    end

    it { is_expected.to be(result) }

    it do
      expect(client).to receive(:write_point)
        .with(key, data, precision, retention)

      write_point
    end
  end
end
