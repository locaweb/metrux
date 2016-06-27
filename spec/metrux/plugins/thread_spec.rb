describe Metrux::Plugins::Thread do
  subject(:plugin) { described_class.new(config, options) }

  let(:config) { Metrux::Configuration.new }
  let(:options) { { tags: { some: 'tag' } } }

  describe '#call' do
    subject(:call) { plugin.call }

    let(:expected_key) { 'Thread.list.count' }

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

      expect(@result).to be(thread_list.count)
    end

    context 'when there is a prefix option' do
      let(:prefix) { 'SomePrefix' }
      let(:options) { { prefix: prefix, tags: { some: 'tag' } } }
      let(:expected_key) { "#{prefix}/Thread.list.count" }

      it do
        expect(Metrux)
          .to receive(:periodic_gauge)
          .with(expected_key, options)

        call
      end
    end
  end
end
