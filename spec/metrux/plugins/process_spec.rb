describe Metrux::Plugins::Process do
  subject(:plugin) { described_class.new(config, options) }

  let!(:config) { build(:configuration) }
  let(:options) { { tags: { some: 'tag' } } }

  describe '#initialize' do
    subject(:init) { plugin }

    it { is_expected.to be_truthy }
  end

  describe '.ancestors' do
    subject(:ancestors) { described_class.ancestors }

    it { is_expected.to include(Metrux::Plugins::PeriodicGauge) }
  end

  describe '#data' do
    subject(:data) { plugin.data }

    let(:expected_data) { { rss: rss } }

    let(:statm_found?) { true }
    let(:rss) { 100_000 }
    let(:pid) { Process.pid }
    let(:pagesize) { 2_048 }
    let(:pagesize_conf) { "#{pagesize}\n" }
    let(:statm_path) { "/proc/#{pid}/statm" }
    let(:statm_rss) { (rss * 1_024) / pagesize }
    let(:statm_content) { "74103 #{statm_rss} 1869 1 0 30688 0\n" }
    let(:host_os) { 'linux-gnu' }

    before do
      @current_os = RbConfig::CONFIG['host_os']
      RbConfig::CONFIG['host_os'] = host_os

      allow(::Kernel)
        .to receive(:`)
        .with('getconf PAGESIZE')
        .and_return(pagesize_conf)

      allow(::File)
        .to receive(:exist?)
        .and_return(statm_found?)

      allow(::File)
        .to receive(:read)
        .with(statm_path)
        .and_return(statm_content)
    end

    after { RbConfig::CONFIG['host_os'] = @current_os }

    it { is_expected.to eq(expected_data) }

    it do
      expect(::File)
        .to receive(:read)
        .with(statm_path)

      data
    end

    context 'when the statm file was not found' do
      let(:statm_found?) { false }
      let(:rss_from_ps) { 10_000 }

      let(:expected_data) { { rss: rss_from_ps } }

      before do
        allow(::Kernel)
          .to receive(:`)
          .with("ps -o rss= -p #{pid}")
          .and_return("#{rss_from_ps}\n")
      end

      it { is_expected.to eq(expected_data) }

      it do
        expect(::Kernel)
          .to receive(:`)
          .with("ps -o rss= -p #{pid}")

        data
      end

      it do
        expect(::File)
          .not_to receive(:read)
          .with(statm_path)

        data
      end

      context 'when something wrong happens on ps rss fecthing' do
        let(:expected_data) { { rss: 0 } }

        before do
          allow(::Kernel)
            .to receive(:`)
            .with("ps -o rss= -p #{pid}")
            .and_raise('something went wrong')
        end

        it { is_expected.to eq(expected_data) }
      end
    end

    context 'when the os is a mac' do
      let(:host_os) { 'darwin15.2.0' }
      let(:rss_from_ps) { 10_000 }

      let(:expected_data) { { rss: rss_from_ps } }

      before do
        allow(::Kernel)
          .to receive(:`)
          .with("ps -o rss= -p #{pid}")
          .and_return("#{rss_from_ps}\n")
      end

      it { is_expected.to eq(expected_data) }

      it do
        expect(::Kernel)
          .to receive(:`)
          .with("ps -o rss= -p #{pid}")

        data
      end

      it do
        expect(::File)
          .not_to receive(:read)
          .with(statm_path)

        data
      end

      context 'when something wrong happens on ps rss fecthing' do
        let(:expected_data) { { rss: 0 } }

        before do
          allow(::Kernel)
            .to receive(:`)
            .with("ps -o rss= -p #{pid}")
            .and_raise('something went wrong')
        end

        it { is_expected.to eq(expected_data) }
      end
    end

    context 'when the os is unknown' do
      let(:host_os) { 'windows' }
      let(:expected_data) { { rss: 0 } }

      it { is_expected.to eq(expected_data) }

      it do
        expect(::Kernel)
          .not_to receive(:`)
          .with("ps -o rss= -p #{pid}")

        data
      end

      it do
        expect(::File)
          .not_to receive(:read)
          .with(statm_path)

        data
      end
    end

    context 'when something wrong happens on statm path fecthing' do
      let(:expected_data) { { rss: 0 } }

      before do
        allow(::File)
          .to receive(:read)
          .with(statm_path)
          .and_raise('something went wrong')
      end

      it { is_expected.to eq(expected_data) }
    end

    context 'when something wrong happens on kernel page size fecthing' do
      let(:pagesize) { 4_096 }

      before do
        allow(::Kernel)
          .to receive(:`)
          .with('getconf PAGESIZE')
          .and_raise('something went wrong')
      end

      it { is_expected.to eq(expected_data) }
    end

    context 'when something wrong happens on statm rss fecthing' do
      let(:expected_data) { { rss: 0 } }

      before do
        allow(::File)
          .to receive(:read)
          .with(statm_path)
          .and_raise('something went wrong')
      end

      it { is_expected.to eq(expected_data) }
    end
  end

  describe '#key' do
    subject(:key) { plugin.key }

    it { is_expected.to eq('process') }
  end
end
