module Metrux
  HOST = Socket.gethostname.freeze
  PROGRAM_NAME = $PROGRAM_NAME
                 .split('/').last
                 .split(' ').first.gsub(/\W/, '')
                 .freeze
end
