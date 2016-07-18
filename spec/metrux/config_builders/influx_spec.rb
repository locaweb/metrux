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

          before do
            @current_env_option = ENV["METRUX_INFLUX_#{key.upcase}"]
            ENV["METRUX_INFLUX_#{key.upcase}"] = option
          end

          after { ENV["METRUX_INFLUX_#{key.upcase}"] = @current_env_option }

          it { is_expected.to eq(option) }
        end
      end

      context 'and the key\'s value is a integer' do
        subject { build[:port] }

        let(:port) { '8083' }

        before do
          @current_env_option = ENV["METRUX_INFLUX_PORT"]
          ENV["METRUX_INFLUX_PORT"] = port
        end

        after { ENV["METRUX_INFLUX_PORT"] = @current_env_option }

        it { is_expected.to eq(port.to_i) }
      end

      context 'and the key\'s value is a float' do
        subject { build[:max_delay] }

        let(:max_delay) { '25.2' }

        before do
          @current_env_option = ENV["METRUX_INFLUX_MAX_DELAY"]
          ENV["METRUX_INFLUX_MAX_DELAY"] = max_delay
        end

        after { ENV["METRUX_INFLUX_MAX_DELAY"] = @current_env_option }

        it { is_expected.to eq(max_delay.to_f) }
      end

      context 'and the key\'s value is a boolean' do
        subject { build[:async] }

        let(:async) { 'true' }

        before do
          @current_env_option = ENV["METRUX_INFLUX_ASYNC"]
          ENV["METRUX_INFLUX_ASYNC"] = async
        end

        after { ENV["METRUX_INFLUX_ASYNC"] = @current_env_option }

        it { is_expected.to eq(true) }

        context 'when it is false' do
          let(:async) { 'false' }

          it { is_expected.to eq(false) }
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
