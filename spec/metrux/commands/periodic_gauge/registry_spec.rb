describe Metrux::Commands::PeriodicGauge::Registry do
  subject(:registry) { described_class.new(config) }

  let(:config) { Metrux::Configuration.new }

  describe '#add' do
    subject(:add) { registry.add(key, &to_be_processed) }

    let(:to_be_processed) { Proc.new { nil } }
    let(:key) { 'my-key' }
    let(:result) { 42 }

    let(:expected_registred_metrics) do
      {
        "#{key}/" => { measurement: key, metric: to_be_processed, options: {} }
      }
    end

    it { is_expected.to be(true) }

    it do
      expect { add }
        .to change { registry.metrics }
        .from({})
        .to(expected_registred_metrics)
    end

    context 'when you use same key but different tags' do
      before do
        registry.add(key, tags: { some: 'thing' })
      end

      it do
        expect { add }
          .to change { registry.metrics.size }
          .from(1)
          .to(2)
      end

      it do
        add

        expect(registry.metrics)
          .to match(hash_including(expected_registred_metrics))
      end
    end

    context 'when some options are passed' do
      subject(:add) { registry.add(key, options, &to_be_processed) }

      let(:tags) { { some: 'tag' } }
      let(:options) { { precision: 's', retention: '1h.cpu', tags: tags } }

      let(:expected_registred_metrics) do
        {
          "#{key}/#{tags.to_query}" => {
            measurement: key, metric: to_be_processed, options: options
          }
        }
      end

      it { is_expected.to be(true) }

      it do
        expect { add }
          .to change { registry.metrics }
          .from({})
          .to(expected_registred_metrics)
      end
    end
  end
end
