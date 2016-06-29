describe Metrux do
  it 'has a version number' do
    expect(Metrux::VERSION).not_to be nil
  end

  available_commands = %i(timer meter gauge periodic_gauge notice_error write)

  it { should delegate_method(:logger).to(:config) }

  describe '.setup' do
    subject(:setup) { described_class.setup }

    context do
      before { Metrux.instance_variable_set('@configured', nil) }

      it do
        expect { setup }.to change { Metrux.configured? }.from(nil).to(true)
      end
    end

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

      expect(Metrux::PluginRegister)
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

    it do
      plugin_register = instance_double(Metrux::PluginRegister)

      allow(Metrux::PluginRegister)
        .to receive(:new)
        .and_return(plugin_register)

      expect { setup }
        .to change { described_class.plugin_register }
        .to(plugin_register)
    end
  end

  available_commands.each do |cmd|
    describe("#{cmd}") { it { should delegate_method(cmd).to(:client) } }
  end

  describe '#plugins' do
    it { should delegate_method(:plugins).to(:plugin_register) }
  end

  describe '#register' do
    it { should delegate_method(:register).to(:plugin_register) }
  end

  describe '#client' do
    subject(:reader) { described_class.client }

    let(:configured?) { true }

    before do
      allow(Metrux).to receive(:configured?).and_return(configured?)
    end

    it { is_expected.to be_a(Metrux::Client) }

    it do
      expect(Metrux).not_to receive(:setup)

      reader
    end

    context 'when it is not configured yet' do
      let(:configured?) { false }

      it { is_expected.to be_a(Metrux::Client) }

      it do
        expect(Metrux).to receive(:setup)

        reader
      end
    end
  end

  describe '#plugin_register' do
    subject(:reader) { described_class.plugin_register }

    let(:configured?) { true }

    before do
      allow(Metrux).to receive(:configured?).and_return(configured?)
    end

    it { is_expected.to be_a(Metrux::PluginRegister) }

    it do
      expect(Metrux).not_to receive(:setup)

      reader
    end

    context 'when it is not configured yet' do
      let(:configured?) { false }

      it { is_expected.to be_a(Metrux::PluginRegister) }

      it do
        expect(Metrux).to receive(:setup)

        reader
      end
    end
  end
end
