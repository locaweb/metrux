describe Metrux::Configuration do
  subject(:config) { described_class.new(config_path) }

  let(:config_path) { 'spec/support/config/metrux.yml' }
  let(:config_from_yaml) do
    YAML.load_file(config_path).fetch('test').with_indifferent_access
  end

  describe '#initialize' do
    subject(:init) { config }

    it { is_expected.to be_a(Metrux::Configuration) }

    context 'when the configuration file was not found' do
      let(:config_path) { 'file_not_found.yml' }

      it do
        expect { init }.to raise_error(
          Metrux::ConfigBuilders::Yaml::FileLoadError,
          /Errno\:\:ENOENT\:\ No\ such\ file\ or\ directory/
        )
      end
    end

    context 'when the configuration file contains ERB templating' do
      let(:config_path) { 'spec/support/config/erb_templating.yml' }

      before { ENV['SOMETHING'] = '43' }
      after { ENV['SOMETHING'] = nil }

      it { is_expected.to be_a(Metrux::Configuration) }

      context 'when the template has an evaluation error' do
        before { ENV['SOMETHING'] = nil }

        it do
          expect { init }.to raise_error(
            Metrux::ConfigBuilders::Yaml::FileLoadError,
            'KeyError: key not found: "SOMETHING"'
          )
        end
      end
    end

    context 'when there is not any configuration for a specific environment' do
      before { ENV['RAILS_ENV'] = '404_environment' }
      after { ENV['RAILS_ENV'] = 'test' }

      let(:config_from_yaml) do
        YAML.load_file(config_path).fetch('development').with_indifferent_access
      end

      before { allow(Kernel).to receive(:warn) }

      it do
        expect(Kernel).to receive(:warn).with(
          "[WARNING] Metrux's configuration wasn't found for environment "\
          "\"404_environment\". Switching to default: \"development\"."
        )

        init
      end

      it { expect(config.app_name).to eq(config_from_yaml[:app_name]) }

      context 'and the default environment was not found' do
        let(:config_path) { 'spec/support/config/without_default_env.yml' }

        it do
          expect { init }.to raise_error(
            Metrux::ConfigBuilders::Yaml::EnvironmentNotFoundError,
            'KeyError: key not found: "development"'
          )
        end
      end
    end
  end

  describe '#env' do
    subject(:env) { config.env }

    before do
      ENV['RAILS_ENV'] = nil
      ENV['RACK_ENV'] = nil
    end

    after do
      ENV['RAILS_ENV'] = 'test'
      ENV['RACK_ENV'] = nil
    end

    it { is_expected.to eq('development') }

    context 'when RAILS_ENV is not defined but RACK_ENV' do
      before do
        ENV['RAILS_ENV'] = nil
        ENV['RACK_ENV'] = 'rack_env_test'
      end

      after do
        ENV['RAILS_ENV'] = 'test'
        ENV['RACK_ENV'] = nil
      end

      it { is_expected.to eq('rack_env_test') }
    end

    context 'when RAILS_ENV is defined but RACK_ENV' do
      before do
        ENV['RAILS_ENV'] = 'test'
        ENV['RACK_ENV'] = nil
      end

      after do
        ENV['RAILS_ENV'] = 'test'
        ENV['RACK_ENV'] = nil
      end

      it { is_expected.to eq('test') }
    end
  end

  describe '#app_name' do
    subject { config.app_name }

    let(:app_name) { config_from_yaml.fetch(:app_name) }

    it { is_expected.to eq(app_name) }

    context 'when the env var is set' do
      let(:app_name_from_env) { 'Awesome app' }

      before { ENV['METRUX_APP_NAME'] = app_name_from_env }

      after { ENV['METRUX_APP_NAME'] = nil }

      it { is_expected.to eq(app_name_from_env) }
    end

    context 'when neither yaml nor env var are defined' do
      before { ENV['RAILS_ENV'] = 'without_app_name' }
      after { ENV['RAILS_ENV'] = 'test' }

      it do
        expect { subject }
          .to raise_error(Metrux::ConfigBuilders::Common::AppNameNotFoundError)
      end
    end
  end

  describe '#prefix' do
    subject { config.prefix }

    let(:app_name) { config_from_yaml.fetch(:app_name) }
    let(:prefix) { 'test_app_test' }

    it { is_expected.to eq(prefix) }

    context 'when the env var is set' do
      let(:app_name_from_env) { 'Caçamba Panel_awesome (TesteLorem)' }
      let(:prefix_from_env) { 'cacamba_panel_awesome_teste_lorem' }

      before { ENV['METRUX_APP_NAME'] = app_name_from_env }

      after { ENV['METRUX_APP_NAME'] = nil }

      it { is_expected.to eq(prefix_from_env) }
    end
  end

  describe '#active?' do
    subject { config.active? }

    it { is_expected.to be(true) }

    context 'when the env var is set' do
      before { ENV['METRUX_ACTIVE'] = 'false' }
      after { ENV['METRUX_ACTIVE'] = nil }

      it { is_expected.to be(false) }
    end

    context 'when neither yaml nor env var are defined' do
      before { ENV['RAILS_ENV'] = 'without_active' }
      after { ENV['RAILS_ENV'] = 'test' }

      it { is_expected.to eq(false) }
    end
  end

  describe '#periodic_gauge_interval' do
    subject { config.periodic_gauge_interval }

    let(:periodic_gauge_interval) do
      config_from_yaml.fetch(:periodic_gauge_interval)
    end

    it { is_expected.to eq(periodic_gauge_interval) }

    context 'when the env var is set' do
      let(:periodic_gauge_interval_from_env) { '120' }

      before do
        ENV['METRUX_PERIODIC_GAUGE_INTERVAL'] = periodic_gauge_interval_from_env
      end

      after { ENV['METRUX_PERIODIC_GAUGE_INTERVAL'] = nil }

      it { is_expected.to eq(periodic_gauge_interval_from_env.to_i) }
    end

    context 'when neither yaml nor env var are defined' do
      before { ENV['RAILS_ENV'] = 'without_periodic_gauge_interval' }
      after { ENV['RAILS_ENV'] = 'test' }

      it { is_expected.to eq(nil) }
    end
  end

  describe '#influx' do
    subject(:influx) { config.influx }

    let(:expected_influx) do
      config_from_yaml
        .reduce(time_precision: 'ns') do |influx, (k, v)|
          if k.start_with?('influx_')
            influx[k.gsub('influx_', '').to_sym] = v
          end
          influx
        end
    end

    it { is_expected.to eq(expected_influx) }

    context 'when the env var is set' do
      %w(host port database username password async).each do |key|
        context "for the key #{key}" do
          subject { influx[key.to_sym] }

          let(:option) { "option_#{key}" }

          before { ENV["METRUX_INFLUX_#{key.upcase}"] = option }

          after { ENV["METRUX_INFLUX_#{key.upcase}"] = nil }

          it { is_expected.to eq(option) }
        end
      end
    end

    context 'when neither yaml nor env var are defined' do
      before { ENV['RAILS_ENV'] = 'without_influx' }
      after { ENV['RAILS_ENV'] = 'test' }

      it do
        expect { influx }.to raise_error(
          Metrux::ConfigBuilders::Influx::ConfigNotFoundError,
          'KeyError: key not found: "influx_host"'
        )
      end
    end
  end

  describe '#logger' do
    subject(:logger) { config.logger }

    let(:log_device) { logger.instance_variable_get(:@logdev) }
    let(:log_file) { log_device.filename }
    let(:expected_log_file) { config_from_yaml[:log_file] }

    it { is_expected.to be_a(::Logger) }
    it { expect(log_file).to eq(expected_log_file) }

    context 'when the env var is set' do
      let(:log_file_from_env) { 'test.log' }

      before do
        ENV['METRUX_LOG_FILE'] = log_file_from_env
      end

      after { ENV['METRUX_LOG_FILE'] = nil }

      it { is_expected.to be_a(::Logger) }
      it { expect(log_file).to eq(log_file_from_env) }
    end

    context 'when neither yaml nor env var are defined' do
      before { ENV['RAILS_ENV'] = 'without_log_file' }
      after { ENV['RAILS_ENV'] = 'test' }

      it { is_expected.to be_a(::Logger) }
      it { expect(log_device.dev).to eq(STDOUT) }
    end

    context 'when the file can\'t be created' do
      before do
        allow(Kernel).to receive(:warn)
        allow(::Logger).to receive(:new).and_raise(
          Errno::EPERM, 'Permission denied'
        )
      end

      it do
        expect(Kernel).to receive(:warn).with(
          /\[WARNING\] Cound\'t configure Metrux\'s logger\.\ Errno\:\:EPERM\:\ /
        )

        logger
      end

      it { is_expected.to be(nil) }
    end
  end
end
