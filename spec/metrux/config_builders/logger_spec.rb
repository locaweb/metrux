describe Metrux::ConfigBuilders::Logger do
  subject(:logger) { described_class.new(yaml) }

  let(:config_path) { 'spec/support/config/metrux.yml' }
  let(:yaml) do
    YAML.load_file(config_path).fetch('test').with_indifferent_access
  end

  describe '#build' do
    subject(:build) { logger.build }

    let(:log_device) { build.instance_variable_get(:@logdev) }
    let(:log_file) { log_device.filename }
    let(:expected_log_file) { yaml[:log_file] }
    let(:log_file_from_env) { nil }

    before do
      @current_log_file = ENV['METRUX_LOG_FILE']
      ENV['METRUX_LOG_FILE'] = log_file_from_env
    end

    after { ENV['METRUX_LOG_FILE'] = @current_log_file }

    it { is_expected.to be_a(::Logger) }
    it { expect(log_file).to eq(expected_log_file) }

    context 'when the it is STDOUT as string' do
      let(:log_file_from_env) { 'STDOUT' }

      it { expect(log_device.dev).to eq(STDOUT) }
    end

    context 'when the env var is set' do
      let(:log_file_from_env) { 'test.log' }

      it { is_expected.to be_a(::Logger) }
      it { expect(log_file).to eq(log_file_from_env) }

      context 'when it is STDOUT as string' do
        let(:log_file_from_env) { 'STDOUT' }

        it { expect(log_device.dev).to eq(STDOUT) }
      end
    end

    context 'when neither yaml nor env var are defined' do
      let(:yaml) { {} }

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

        build
      end

      it { is_expected.to be(nil) }
    end
  end
end
