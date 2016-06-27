shared_context 'for commands', type: :command do
  let(:host) { Socket.gethostname }
  let(:default_tags) do
    {
      hostname: host, uniq: uniq, app_name: app_name,
      program_name: program_name
    }
  end

  let(:program_name) { 'rspec' }
  let(:app_name) { config.app_name }
  let(:uniq) { 'uniq-random-id' }
  let(:now) { Time.new(2016, 1, 1) }
  let(:now_timestamp) { now.utc.to_i }

  before do
    allow(SecureRandom).to receive(:hex).and_return(uniq)
    allow(Time).to receive(:now).and_return(now)
  end
end
