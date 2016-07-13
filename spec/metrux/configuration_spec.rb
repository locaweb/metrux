describe Metrux::Configuration do
  subject(:config) { described_class.new(config_path) }

  let(:config_path) { 'spec/support/config/metrux.yml' }
  let(:config_from_yaml) do
    YAML.load_file(config_path).fetch('test').with_indifferent_access
  end

  it { is_expected.to be_truthy }

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

    it { is_expected.to be_a(::Hash) }
  end

  describe '#logger' do
    subject(:logger) { config.logger }

    it { is_expected.to be_a(::Logger) }
  end
end
