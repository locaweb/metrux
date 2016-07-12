describe Metrux::Commands::PeriodicGauge::Supervisor do
  subject(:supervisor) { described_class.new(agent, config) }

  let(:agent) { instance_double(Metrux::Commands::PeriodicGauge::Agent) }
  let(:config) { build(:configuration) }

  let(:instance) { supervisor }
  it_behaves_like 'sleeper'

  describe '#start' do
    subject(:start) { supervisor.start }

    let(:agent_alive?) { true }
    let(:fake_interval) { 0.01 }

    before do
      allow(supervisor).to receive(:wait) { sleep(fake_interval) }
      allow(agent).to receive(:alive?).and_return(agent_alive?)
    end

    it { is_expected.to be(true) }

    it do
      expect(agent).not_to receive(:start)

      start
    end

    context 'when the agent is dead' do
      before do
        allow(agent).to receive(:alive?).and_return(false, true)
      end

      it do
        expect(agent).to receive(:start).once

        start && sleep(0.1)
      end
    end

    context 'when the supervisor has already been started' do
      before { allow(supervisor).to receive(:alive?).and_return(true) }

      it { is_expected.to be(false) }

      it do
        expect(Thread).not_to receive(:new)

        start
      end
    end
  end

  describe '#stop' do
    subject(:stop) { supervisor.stop }

    let!(:thread) { Thread.new { sleep(2) } }

    before { allow(Thread).to receive(:new).and_return(thread) }

    it do
      supervisor.start
      supervisor.stop

      # The thread doesn't die immediately :(
      sleep(0.05)

      expect(thread).not_to be_alive
    end

    context 'when the supervisor hasn\'t been started yet' do
      it do
        supervisor.stop

        # The thread doesn't die immediately :(
        sleep(0.05)

        expect(thread).to be_alive
      end
    end
  end

  describe '#alive?' do
    subject(:alive?) { supervisor.alive? }

    let!(:thread) { Thread.new { sleep(5) } }

    before { allow(Thread).to receive(:new).and_return(thread) }

    it do
      supervisor.start
      expect(alive?).to be(true)
    end

    context 'when the thread is dead' do
      it do
        supervisor.start
        thread.kill

        # The thread doesn't die immediately :(
        sleep(0.05)

        expect(alive?).to be(false)
      end
    end

    context 'when the supervisor hasn\'t been started yet' do
      it do
        expect(alive?).to be_falsey
      end
    end
  end
end
