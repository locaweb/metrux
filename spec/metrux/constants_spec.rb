describe Metrux do
  describe '::HOST' do
    subject(:constant) { described_class::HOST }

    it { is_expected.to eq(Socket.gethostname) }
  end

  describe '::PROGRAM_NAME' do
    subject(:constant) { described_class::PROGRAM_NAME }

    let(:full_program_name)  { 'bin/sidekiq' }

    let(:consts) { %i(HOST PROGRAM_NAME MAIN_PROGRAM_NAME PUMA_WORKER) }

    let(:expected) { 'sidekiq' }

    before do
      @original_program_name = $PROGRAM_NAME
      $PROGRAM_NAME = full_program_name

      consts.each(&remove_const)
      load 'lib/metrux/constants.rb'
    end

    after do
      $PROGRAM_NAME = @original_program_name

      consts.each(&remove_const)
      load 'lib/metrux/constants.rb'
    end

    it { is_expected.to eq(expected) }

    context 'when it is running under puma' do
      let(:full_program_name)  { 'bin/puma: cluster worker 42: 1234' }
      let(:expected) { 'puma-42' }

      it { is_expected.to eq(expected) }
    end
  end
end

def remove_const
  lambda do |const_name|
    if Metrux.const_defined?(const_name)
      Metrux.send(:remove_const, const_name)
    end
  end
end
