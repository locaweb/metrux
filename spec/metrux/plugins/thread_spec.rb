describe Metrux::Plugins::Thread do
  subject(:plugin) { described_class.new(config, options) }

  let(:config) { Metrux::Configuration.new }
  let(:options) { { tags: { some: 'tag' } } }

  describe '#call' do
    subject(:call) { plugin.call }

    let(:expected_key) { 'thread' }

    it do
      expect(Metrux)
        .to receive(:periodic_gauge)
        .with(expected_key, options)

      call
    end

    it do
      @result = nil

      allow(Metrux)
        .to receive(:periodic_gauge)
        .with(expected_key, options) { |*_, &blk| @result = blk.call }

      thread_list = 42.times.map(&:to_i)

      allow(::Thread).to receive(:list).and_return(thread_list)

      call

      expect(@result).to eq(count: thread_list.count)
    end
  end
end
