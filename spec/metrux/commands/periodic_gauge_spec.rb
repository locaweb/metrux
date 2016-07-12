describe Metrux::Commands::PeriodicGauge, type: :command do
  subject(:command) { described_class.new(config, connection) }

  let(:config) { build(:configuration) }
  let(:connection) do
    instance_double(Metrux::Connections::InfluxDb, write_point: nil)
  end

  describe '#initialize' do
    it { is_expected.to be_truthy }

    it do
      expect(Metrux::Commands::PeriodicGauge::Registry)
        .to receive(:new)
        .with(config)
        .and_call_original

      command
    end

    it do
      registry = instance_double(Metrux::Commands::PeriodicGauge::Registry)

      allow(Metrux::Commands::PeriodicGauge::Registry)
        .to receive(:new)
        .and_return(registry)

      expect(Metrux::Commands::PeriodicGauge::Reporter)
        .to receive(:new)
        .with(instance_of(Metrux::Commands::PeriodicGauge), registry, config)
        .and_call_original

      command
    end
  end

  describe '#execute' do
    subject(:execute) { command.execute(key) { @counter += 1; result } }

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

    let(:interval) { config.periodic_gauge_interval }

    let(:fake_interval) { 0.1 }
    let(:wait_execution) do
      -> (times = 1) do
        tries = 0
        loop do
          sleep(0.01) && tries += 1
          break if @counter >= times || tries >= 500
        end
      end
    end

    before do
      @counter = 0
      allow_any_instance_of(Metrux::Commands::PeriodicGauge::Agent)
        .to receive(:wait) { sleep(fake_interval) }
    end

    it { is_expected.to be(true) }

    it do
      expect(connection)
        .to receive(:write_point)
        .with(expected_key, expected_data, nil, nil)
        .twice

      expect_any_instance_of(Metrux::Commands::PeriodicGauge::Agent)
        .to receive(:wait)
        .with(interval)

      execute && wait_execution.call(2)
    end

    context 'when the data is a Hash' do
      let(:result) { { multi: :value } }
      let(:expected_data) do
        { values: result, tags: expected_tags, timestamp: now_timestamp }
      end

      it do
        expect(connection)
          .to receive(:write_point)
          .with(expected_key, expected_data, nil, nil)

        expect_any_instance_of(Metrux::Commands::PeriodicGauge::Agent)
          .to receive(:wait)
          .with(interval)

        execute && wait_execution.call
      end
    end

    context 'when some options are passed' do
      subject(:execute) do
        command.execute(key, options) { @counter += 1; result }
      end

      let(:tags) { { some: 'tag' } }
      let(:options) { { precision: 's', retention: '1h.cpu', tags: tags } }

      let(:expected_tags) { default_tags.merge(tags) }

      it do
        expect(connection)
          .to receive(:write_point)
          .with(expected_key, expected_data, 's', '1h.cpu')

        expect_any_instance_of(Metrux::Commands::PeriodicGauge::Agent)
          .to receive(:wait)
          .with(interval)

        execute && wait_execution.call
      end
    end
  end
end
