module Metrux
  module Plugins
  end
end

require_relative 'plugins/periodic_gauge'
require_relative 'plugins/gc'
require_relative 'plugins/process'
require_relative 'plugins/thread'
require_relative 'plugins/yarv'
