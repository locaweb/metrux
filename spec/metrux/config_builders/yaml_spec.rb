describe Metrux::ConfigBuilders::Yaml do
  subject(:builder) { described_class.new(config_path, env) }

  let(:config_path) { 'spec/support/config/metrux.yml' }
  let(:env) { 'test' }

  describe '#build' do
    subject(:build) { builder.build}

    let(:expected_content) do
      YAML.load_file(config_path).with_indifferent_access[env]
    end

    it { is_expected.to eq(expected_content) }

    context 'when the file doesn\'t exist' do
      let(:config_path) { 'non_existant.yml' }
      let(:expected_content) { {} }

      it { is_expected.to eq(expected_content) }
    end

    context 'when doesn\'t have the environment key on config file' do
      let(:env) { 'non_existant' }

      let(:expected_content) do
        YAML.load_file(config_path).with_indifferent_access['development']
      end

      before { allow(Kernel).to receive(:warn) }

      it { is_expected.to eq(expected_content) }

      it do
        expect(Kernel).to receive(:warn).with(
          "[WARNING] Metrux's configuration wasn't found for environment "\
          "\"non_existant\". Switching to default: \"development\"."
        )

        build
      end

      context 'and the default environment was not found' do
        let(:config_path) { 'spec/support/config/without_default_env.yml' }

        it do
          expect { build }.to raise_error(
            Metrux::ConfigBuilders::Yaml::EnvironmentNotFoundError,
            'KeyError: key not found: "development"'
          )
        end
      end
    end

    context 'when the configuration file contains ERB templating' do
      let(:config_path) { 'spec/support/config/erb_templating.yml' }

      let(:variable) { '42' }

      let(:expected_content) do
        content = File.read(config_path)
        template = ERB.new(content)
        YAML.load(template.result)[env]
      end

      before { ENV['SOMETHING'] = variable }
      after { ENV['SOMETHING'] = nil }

      it { is_expected.to eq(expected_content) }

      it { expect(build[:app_name]).to eq("Test app #{variable}") }

      context 'when the template has an evaluation error' do
        before { ENV['SOMETHING'] = nil }

        it do
          expect { build }.to raise_error(
            Metrux::ConfigBuilders::Yaml::FileLoadError,
            'KeyError: key not found: "SOMETHING"'
          )
        end
      end
    end
  end
end
