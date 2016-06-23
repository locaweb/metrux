shared_examples 'sleeper' do
  describe '#wait' do
    subject(:wait) { instance.wait(seconds) }

    let(:seconds) { 10 }

    it do
      expect(Kernel).to receive(:sleep).with(seconds)

      wait
    end
  end
end
