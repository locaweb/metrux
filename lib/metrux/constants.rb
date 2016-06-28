module Metrux
  HOST = Socket.gethostname.freeze
  MAIN_PROGRAM_NAME = $PROGRAM_NAME
                      .split('/').last
                      .split(' ').first.gsub(/\W/, '')
                      .freeze
  PUMA_WORKER =
    $PROGRAM_NAME
    .split('/').last
    .scan(/^puma: cluster worker (\d+): */)
    .flatten.last
    .freeze

  PROGRAM_NAME = if PUMA_WORKER.present?
                   "#{MAIN_PROGRAM_NAME}-#{PUMA_WORKER}"
                 else
                   MAIN_PROGRAM_NAME
                 end.freeze
end
