describe Metrux::Client do
  subject(:client) { described_class.new(config) }

  let(:config) { build(:configuration) }

  available_commands = %i(timer meter gauge periodic_gauge notice_error write)

  describe '::AVAILABLE_COMMANDS' do
    subject(:commands) { described_class::AVAILABLE_COMMANDS }

    it { is_expected.to eq(available_commands) }
  end

  describe '#initialize' do
    subject(:init) { client }

    let(:connection) { instance_double(Metrux::Connections::InfluxDb) }

    before do
      allow(Metrux::Connections::InfluxDb)
        .to receive(:new)
        .and_return(connection)
    end

    available_commands.each do |cmd|
      it "instantiate the command #{cmd}" do
        command_class = "metrux/commands/#{cmd}".camelize.constantize

        expect(command_class)
          .to receive(:new)
          .with(config, connection)
          .at_least(:once)
          .and_call_original

        init
      end
    end

    context 'when Metrux is not active' do
      let(:null_conn) { instance_double(Metrux::Connections::Null) }

      before do
        allow(Metrux::Connections::Null)
          .to receive(:new)
          .and_return(null_conn)

        allow(config).to receive(:active?).and_return(false)
      end

      available_commands.each do |cmd|
        it "instantiate the command #{cmd}" do
          command_class = "metrux/commands/#{cmd}".camelize.constantize

          expect(command_class)
            .to receive(:new)
            .with(config, null_conn)
            .at_least(:once)
            .and_call_original

          init
        end
      end
    end
  end

  available_commands.each do |cmd|
    describe "#{cmd}" do
      it { should delegate_method(cmd).to(:"#{cmd}_command").as(:execute) }

      it "executes the command #{cmd}" do
        command_class = "metrux/commands/#{cmd}".camelize.constantize
        command_args = command_class
          .instance_method(:execute)
          .parameters
          .map { |it| { it[1] => rand(20) } }

        command = instance_double(command_class, :execute)

        allow(command_class)
          .to receive(:new)
          .and_return(command)

        expect(command)
          .to receive(:execute)
          .with(*command_args)

        client.public_send(cmd, *command_args)
      end
    end
  end
end

