describe Metrux::Commands::PeriodicGauge::Agent do
  subject(:agent) { described_class.new(command, registry, config) }

  let(:connection) do
    instance_double(Metrux::Connections::InfluxDb, write_point: nil)
  end

  let(:config) { Metrux::Configuration.new }
  let(:command) { Metrux::Commands::PeriodicGauge.new(config, connection) }
  let(:registry) { Metrux::Commands::PeriodicGauge::Registry.new(config) }

  let(:instance) { agent }
  it_behaves_like 'sleeper'

  describe '#start' do
    subject(:start) { agent.start }

    let(:key_1) { 'my_key_1' }
    let(:key_2) { 'my_key_2' }
    let(:key_3) { 'my_key_3' }

    let(:tags_1) { { tag: '1' } }
    let(:tags_2) { { tag: '2' } }

    let(:options_1) do
      { tags: tags_1, precision: 's', retention: '1h.cpu' }
    end

    let(:options_2) { { tags: tags_2 } }

    let(:result_1) { 42 }
    let(:result_2) { 43 }

    let(:tags) { { some: 'tag' } }
    let(:options) { { precision: 's', retention: '1h.cpu', tags: tags } }

    let(:expected_tags) { default_tags.merge(tags) }

    let(:expected_key_1) { "gauges/#{key_1}" }
    let(:expected_key_2) { "gauges/#{key_2}" }
    let(:expected_key_3) { "gauges/#{key_3}" }

    let(:expected_data_1) do
      { values: { value: result_1 }, tags: hash_including(tags_1) }
    end

    let(:expected_data_2) do
      { values: { value: result_2 }, tags: hash_including(tags_2) }
    end

    let(:interval) { config.periodic_gauge_interval }
    let(:wait_execution) do
      -> (times = 1) do
        tries = 0
        loop do
          sleep(0.1) && tries =+ 1
          break if @counter >= times || tries >= 10
        end
      end
    end

    let(:fake_interval) { 0.25 }

    before do
      @counter = 0
      allow(agent).to receive(:wait) { sleep(fake_interval) }
      registry.add(key_1, options_1) { result_1 }
      registry.add(key_2, options_2) { result_2 }
      registry.add(key_3) { @counter += 1 ; fail('something went wrong') }
    end

    it { is_expected.to be(true) }

    it do
      expect(Thread).to receive(:new).and_call_original

      start
    end

    it do
      expect(connection)
        .to receive(:write_point)
        .with(expected_key_1, hash_including(expected_data_1), 's', '1h.cpu')
        .twice

      expect(connection)
        .to receive(:write_point)
        .with(expected_key_2, hash_including(expected_data_2), nil, nil)
        .twice

      expect(connection)
        .not_to receive(:write_point)
        .with(expected_key_3, anything, anything, anything)

      expect(agent)
        .to receive(:wait)
        .with(interval)

      start && wait_execution.call(2)
    end

    context 'when the agent has already been started' do
      before { allow(agent).to receive(:alive?).and_return(true) }

      it { is_expected.to be(false) }

      it do
        expect(Thread).not_to receive(:new)

        start
      end
    end
  end

  describe '#stop' do
    subject(:stop) { agent.stop }

    let!(:thread) { Thread.new { sleep(2) } }

    before { allow(Thread).to receive(:new).and_return(thread) }

    it do
      agent.start
      agent.stop

      # The thread doesn't die immediately :(
      sleep(0.05)

      expect(thread).not_to be_alive
    end

    context 'when the agent hasn\'t been started yet' do
      it do
        agent.stop

        # The thread doesn't die immediately :(
        sleep(0.05)

        expect(thread).to be_alive
      end
    end
  end

  describe '#alive?' do
    subject(:alive?) { agent.alive? }

    let!(:thread) { Thread.new { sleep(5) } }

    before { allow(Thread).to receive(:new).and_return(thread) }

    it do
      agent.start
      expect(alive?).to be(true)
    end

    context 'when the thread is dead' do
      it do
        agent.start
        thread.kill

        # The thread doesn't die immediately :(
        sleep(0.05)

        expect(alive?).to be(false)
      end
    end

    context 'when the agent hasn\'t been started yet' do
      it do
        expect(alive?).to be_falsey
      end
    end
  end
end
