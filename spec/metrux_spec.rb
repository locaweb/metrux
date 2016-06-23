describe Metrux do
  it 'has a version number' do
    expect(Metrux::VERSION).not_to be nil
  end

  available_commands = %i(timer meter gauge periodic_gauge notice_error write)

  it { should delegate_method(:logger).to(:config) }

  describe '.setup' do
    subject(:setup) { described_class.setup }

    it do
      expect(Metrux::Configuration)
        .to receive(:new)
        .and_call_original

      setup
    end

    it do
      configuration = Metrux::Configuration.new

      allow(Metrux::Configuration)
        .to receive(:new)
        .and_return(configuration)

      expect(Metrux::Client)
        .to receive(:new)
        .with(configuration)
        .and_call_original

      setup
    end

    it do
      configuration = Metrux::Configuration.new

      allow(Metrux::Configuration)
        .to receive(:new)
        .and_return(configuration)

      expect { setup }
        .to change { described_class.config }
        .to(configuration)
    end

    it do
      client = instance_double(Metrux::Client)

      allow(Metrux::Client)
        .to receive(:new)
        .and_return(client)

      expect { setup }
        .to change { described_class.client }
        .to(client)
    end
  end

  available_commands.each do |cmd|
    describe("#{cmd}") { it { should delegate_method(cmd).to(:client) } }
  end
end
