describe Metrux::Plugins::Process do
  subject(:plugin) { described_class.new(config, options) }

  let!(:config) { build(:configuration) }
  let(:options) { { tags: { some: 'tag' } } }

  describe '#initialize' do
    subject(:init) { plugin }

    it { is_expected.to be_truthy }
  end

  describe '#call' do
    subject(:call) { plugin.call }

    let(:statm_found?) { true }
    let(:rss) { 100_000 }
    let(:pagesize) { 4_096 }
    let(:pagesize_conf) { "#{pagesize}\n" }
    let(:statm_path) { "/proc/#{Process.pid}/statm" }
    let(:statm_rss) { rss * 1_024/ pagesize }
    let(:statm_content) { "74103 #{statm_rss} 1869 1 0 30688 0\n" }
    let(:host_os) { 'linux-gnu' }

    let(:expected_key) { 'process' }

    before do
      @result = nil

      @current_os = RbConfig::CONFIG['host_os']
      RbConfig::CONFIG['host_os'] = host_os

      allow(::Kernel)
        .to receive(:`)
        .with('getconf PAGESIZE')
        .and_return(pagesize_conf)

      allow(::File)
        .to receive(:exist?)
        .and_return(statm_found?)

      allow(::File).to receive(:read).and_call_original

      allow(::File)
        .to receive(:read)
        .with(statm_path)
        .and_return(statm_content)
    end

    after { RbConfig::CONFIG['host_os'] = @current_os }

    it do
      allow(Metrux)
        .to receive(:periodic_gauge)
        .with('process', anything) do |*_, &blk|
        @result = blk.call
      end

      call

      expect(@result).to eq(rss: rss)
    end

    it do
      expect(Metrux)
        .to receive(:periodic_gauge)
        .with(expected_key, options)

      call
    end

    context 'when the statm file was not found' do
      let(:statm_found?) { false }
      let(:pid) { Process.pid }

      before do
        allow(::Kernel)
          .to receive(:`)
          .with("ps -o rss= -p #{pid}")
          .and_return("#{rss}\n")
      end

      it do
        allow(Metrux)
          .to receive(:periodic_gauge)
          .with('process', anything) do |*_, &blk|
          @result = blk.call
        end

        call

        expect(@result).to eq(rss: rss)
      end
    end

    context 'when the os is a mac' do
      let(:host_os) { 'darwin15.2.0' }
      let(:pid) { Process.pid }

      before do
        allow(::Kernel)
          .to receive(:`)
          .with("ps -o rss= -p #{pid}")
          .and_return("#{rss}\n")
      end

      it do
        allow(Metrux)
          .to receive(:periodic_gauge)
          .with('process', anything) do |*_, &blk|
          @result = blk.call
        end

        call

        expect(@result).to eq(rss: rss)
      end
    end

    context 'when the os is unknown' do
      let(:host_os) { 'windows' }

      it do
        allow(Metrux)
          .to receive(:periodic_gauge)
          .with('process', anything) do |*_, &blk|
          @result = blk.call
        end

        call

        expect(@result).to eq(rss: 0)
      end
    end

    context 'when something wrong happens during fetching' do
      before do
        allow(::File)
          .to receive(:read)
          .with(statm_path)
          .and_raise('something went wrong')
      end

      it do
        allow(Metrux)
          .to receive(:periodic_gauge)
          .with('process', anything) do |*_, &blk|
          @result = blk.call
        end

        call

        expect(@result).to eq(rss: 0)
      end
    end
  end
end
