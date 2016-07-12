module Metrux
  module ConfigBuilders
    class Yaml
      FileLoadError = Class.new(ConfigurationError)
      EnvironmentNotFoundError = Class.new(FileLoadError)

      def initialize(config_path, env)
        @config_path = config_path
        @env = env
      end

      def build
        file_exists? ? yaml_content : null_content
      end

      private

      attr_reader :config_path, :env

      def file_exists?
        File.exist?(config_path)
      end

      def null_content
        {}
      end

      def yaml_content
        from_environment(load_file(config_path)).with_indifferent_access
      end

      def load_file(config_path)
        content = File.read(config_path)
        template = ERB.new(content)
        YAML.load(template.result)
      rescue => e
        raise(FileLoadError, "#{e.class}: #{e.message}")
      end

      def from_environment(config_content)
        config_content.fetch(env)
      rescue KeyError => e
        if env == default_environment
          raise(EnvironmentNotFoundError, "#{e.class}: #{e.message}")
        end

        warn_environment_change
        @env = default_environment
        retry
      end

      def default_environment
        Configuration::DEFAULT_ENVIRONMENT
      end

      def warn_environment_change
        Kernel.warn(
          "[WARNING] Metrux's configuration wasn't found for environment "\
          "\"#{env}\". Switching to default: \"#{default_environment}\"."
        )
      end
    end
  end
end
