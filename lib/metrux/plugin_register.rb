module Metrux
  class PluginRegister
    include Loggable

    # Registered plugins
    attr_reader :plugins

    def initialize(config)
      @config = config
      @logger = config.logger
      @plugins = []
    end

    # Register a plugin
    #
    # == Arguments
    #
    # * +klass+ - The plugin class
    # * +options+ - Any option that you might use on plugin
    # * +block+ - If you don't have a class, you can pass a block that receives
    #   the `config` and `options` as arguments.
    #
    # === Examples
    #
    # * Passing a class as plugin
    #
    #     plugin_register.register(
    #       Metrux::Plugins::MyPlugin, tags: { a: 'tag' }
    #     ) # => true
    #
    # * Passing a block as plugin
    #
    #     plugin_register.register(tags: { a: 'tag' }) do |config, options|
    #       # do something
    #     end # => true
    #
    def register(klass = nil, **options)
      plugin = if block_given?
                 -> () { yield(config, options) }
               else
                 klass.new(config, options)
               end

      log("Registering plugin #{plugin.class}")

      plugin.call

      @plugins << plugin

      true
    end

    private

    attr_reader :config, :logger
  end
end
