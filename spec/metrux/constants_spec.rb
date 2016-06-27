describe Metrux do
  describe '::HOST' do
    subject(:constant) { described_class::HOST }

    it { is_expected.to eq(Socket.gethostname) }
  end

  describe '::PROGRAM_NAME' do
    subject(:constant) { described_class::PROGRAM_NAME }

    let(:full_program_name)  { 'bin/puma: cluster worker 0: 1234' }

    let(:consts) { %i(HOST PROGRAM_NAME) }

    let(:expected) { 'puma' }

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
  end
end

def remove_const
  lambda do |const_name|
    if Metrux.const_defined?(const_name)
      Metrux.send(:remove_const, const_name)
    end
  end
end
