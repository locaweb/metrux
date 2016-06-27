module Metrux
  module Plugins
    class Dummy
      def initialize(*_args); end
      def call; end
    end
  end
end

describe Metrux::PluginRegister do
  subject(:plugin_register) { described_class.new(config) }

  let(:config) { Metrux::Configuration.new }

  describe '.register' do
    subject(:register) { plugin_register.register(plugin) }

    let(:plugin) { Metrux::Plugins::Dummy }
    let(:expected_options) { { } }

    it { is_expected.to be(true) }

    it do
      expect(plugin)
        .to receive(:new)
        .with(config, expected_options)
        .and_call_original

      register
    end

    it do
      plugin_instance = plugin.new

      allow(plugin)
        .to receive(:new)
        .and_return(plugin_instance)

      expect(plugin_instance)
        .to receive(:call)
        .with(no_args)
        .and_call_original

      expect { register }
        .to change { plugin_register.plugins }
        .from([])
        .to([plugin_instance])
    end

    context 'when it receives some options' do
      subject(:register) { plugin_register.register(plugin, options) }

      let(:options) { { some: :options, tags: { some: 'tag' } } }
      let(:expected_options) { options }

      it do
        expect(plugin)
          .to receive(:new)
          .with(config, expected_options)
          .and_call_original

        register
      end
    end

    context 'when it receives a proc as a plugin definition' do
      subject(:register) { plugin_register.register(&plugin) }

      let(:plugin) { -> (config, options) { plugin_spy.exec(config, options) } }
      let(:plugin_spy) { spy('plugin_spy') }

      it do
        expect(plugin_spy)
          .to receive(:exec)
          .with(config, expected_options)

        register
      end
    end

    context 'when it receives a proc as a plugin definition a nd ' do
      subject(:register) { plugin_register.register(options, &plugin) }

      let(:plugin) { -> (config, options) { plugin_spy.exec(config, options) } }
      let(:plugin_spy) { spy('plugin_spy') }

      let(:options) { { some: :options, tags: { some: 'tag' } } }
      let(:expected_options) { options }

      it do
        expect(plugin_spy)
          .to receive(:exec)
          .with(config, expected_options)

        register
      end

      it do
        expect { register }
          .to change { plugin_register.plugins }
          .from([])
          .to([kind_of(Proc)])
      end
    end
  end
end
