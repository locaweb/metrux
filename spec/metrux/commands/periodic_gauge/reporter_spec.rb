describe Metrux::Commands::PeriodicGauge::Reporter do
  subject(:reporter) { described_class.new(command, registry, config) }

  let(:config) { Metrux::Configuration.new }
  let(:command) { instance_double(Metrux::Commands::PeriodicGauge) }
  let(:registry) { instance_double(Metrux::Commands::PeriodicGauge::Registry) }

  it { is_expected.to be_truthy }

  describe '#initialize' do
    subject(:init) { reporter }

    it do
      expect(Metrux::Commands::PeriodicGauge::Agent)
        .to receive(:new)
        .with(command, registry, config)
        .and_call_original

      init
    end

    it do
      agent = instance_double(Metrux::Commands::PeriodicGauge::Agent)

      allow(Metrux::Commands::PeriodicGauge::Agent)
        .to receive(:new).and_return(agent)

      expect(Metrux::Commands::PeriodicGauge::Supervisor)
        .to receive(:new)
        .with(agent, config)
        .and_call_original

      init
    end
  end

  describe '#start' do
    subject(:start) { reporter.start }

    let(:agent) do
      instance_double(Metrux::Commands::PeriodicGauge::Agent, start: nil)
    end
    let(:supervisor) do
      instance_double(Metrux::Commands::PeriodicGauge::Supervisor, start: nil)
    end

    before do
      allow(Metrux::Commands::PeriodicGauge::Agent)
        .to receive(:new).and_return(agent)

      allow(Metrux::Commands::PeriodicGauge::Supervisor)
        .to receive(:new).and_return(supervisor)
    end

    it { is_expected.to be(true) }

    it do
      expect(agent).to receive(:start)

      start
    end

    it do
      expect(supervisor).to receive(:start)

      start
    end

    context 'when metrux is not active' do
      let(:config) { object_double(Metrux::Configuration.new, active?: false) }

      it { is_expected.to be(false) }

      it do
        expect(agent).not_to receive(:start)

        start
      end

      it do
        expect(supervisor).not_to receive(:start)

        start
      end
    end
  end

  describe '#stop' do
    subject(:stop) { reporter.stop }

    let(:agent) do
      instance_double(Metrux::Commands::PeriodicGauge::Agent, stop: nil)
    end
    let(:supervisor) do
      instance_double(Metrux::Commands::PeriodicGauge::Supervisor, stop: nil)
    end

    before do
      allow(Metrux::Commands::PeriodicGauge::Agent)
        .to receive(:new).and_return(agent)

      allow(Metrux::Commands::PeriodicGauge::Supervisor)
        .to receive(:new).and_return(supervisor)
    end

    it do
      expect(agent).to receive(:stop)

      stop
    end

    it do
      expect(supervisor).to receive(:stop)

      stop
    end
  end
end
