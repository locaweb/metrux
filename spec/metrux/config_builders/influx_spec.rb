describe Metrux::ConfigBuilders::Influx do
  subject(:influx) { described_class.new(yaml) }

  let(:env) { 'test' }
  let(:config_path) { 'spec/support/config/metrux.yml' }
  let(:yaml) do
    YAML.load_file(config_path).fetch(env).with_indifferent_access
  end

  describe '#build' do
    subject(:build) { influx.build }

    let(:expected_influx) do
      yaml
        .reduce(time_precision: 'ns') do |influx, (k, v)|
          if k.start_with?('influx_')
            influx[k.gsub('influx_', '').to_sym] = v
          end
          influx
        end
    end

    before do
      @current_env = ENV['RAILS_ENV']
      ENV['RAILS_ENV'] = env
    end

    after { ENV['RAILS_ENV'] = @current_env }

    it { is_expected.to eq(expected_influx) }

    context 'when the env var is set' do
      %w(host port database username password async).each do |key|
        context "for the key #{key}" do
          subject { build[key.to_sym] }

          let(:option) { "option_#{key}" }

          before { ENV["METRUX_INFLUX_#{key.upcase}"] = option }

          after { ENV["METRUX_INFLUX_#{key.upcase}"] = nil }

          it { is_expected.to eq(option) }
        end
      end
    end

    context 'when neither yaml nor env var are defined' do
      let(:env) { 'without_influx' }
      let(:expected_influx) { { time_precision: 'ns', async: true } }

      it { is_expected.to eq(expected_influx) }
    end
  end
end
