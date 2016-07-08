shared_context 'for commands', type: :command do
  let(:host) { Socket.gethostname }
  let(:default_tags) do
    {
      hostname: host, app_name: app_name,
      program_name: program_name, env: env
    }
  end

  let(:env) { config.env }
  let(:program_name) { 'rspec' }
  let(:app_name) { config.app_name }
  let(:now) { Time.new(2016, 1, 1) }
  let(:now_timestamp) { (now.utc.to_f * 1_000_000_000).to_i }

  before do
    allow(Time).to receive(:now).and_return(now)
  end
end
