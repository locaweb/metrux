module Metrux
  module Loggable
    PREFIX_PROGRAM_NAME = 'metrux'.freeze
    private_constant :PREFIX_PROGRAM_NAME

    PROGRAM_NAME = $PROGRAM_NAME
                   .split('/').last
                   .split(' ').first.gsub(/\W/, '')
                   .freeze
    private_constant :PROGRAM_NAME

    LOG_PROGRAM_NAME = "#{PREFIX_PROGRAM_NAME}/#{PROGRAM_NAME}".freeze
    private_constant :LOG_PROGRAM_NAME

    private

    def log(message, severity = :debug)
      return if __logger__.blank?

      __logger__.public_send(severity, LOG_PROGRAM_NAME) do
        "[#{self.class}][thread=#{Thread.current.object_id.to_s(16)}] " \
        "#{message}"
      end
    end

    def __logger__
      @logger || Metrux.logger
    end
  end
end
