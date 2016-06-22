describe Metrux::Connections::Null do
  subject(:connection) { described_class.new(config) }

  let(:config) { Metrux::Configuration.new }

  describe '#write_point' do
    subject(:write_point) { connection.write_point(*args) }

    let(:args) { [key, data, precision, retention] }
    let(:logger) { config.logger }
    let(:key) { 'a-measure-key' }
    let(:data) { { values: { value: 1 }, tags: { some: 'tag' } } }
    let(:precision) { 's' }
    let(:retention) { '1h.cpu' }

    it { is_expected.to be(connection) }

    it do
      expect(connection)
        .to receive(:log)
        .with("Calling write_point with #{args}. Block given? false")

      write_point
    end

    context 'when a block is given' do
      subject(:write_point) { connection.write_point(*args) { rand } }

      it { is_expected.to be(connection) }

      it do
        expect(connection)
          .to receive(:log)
          .with("Calling write_point with #{args}. Block given? true")

        write_point
      end
    end
  end
end

