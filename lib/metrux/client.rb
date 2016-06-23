module Metrux
  class Client
    extend Forwardable
    include Loggable

    AVAILABLE_COMMANDS = %i(
      timer meter gauge periodic_gauge notice_error write
    ).freeze

    AVAILABLE_COMMANDS.each do |command|
      attr_reader(:"#{command}_command")
      def_delegator(:"#{command}_command", :execute, command)
    end

    def initialize(config)
      @config = config

      conn_type = config.active? ? 'influx_db' : 'null'
      @connection =
        "metrux/connections/#{conn_type}".camelize.constantize.new(config)

      instantiate_commands
    end

    private

    attr_reader :config, :connection

    def instantiate_commands
      AVAILABLE_COMMANDS.each do |command|
        instance_variable_set(
          "@#{command}_command",
          "metrux/commands/#{command}".camelize.constantize.new(
            config, connection
          )
        )
      end
    end
  end
end
