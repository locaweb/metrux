module Metrux
  # For speeding up tests
  module Sleeper
    def wait(seconds)
      Kernel.sleep(seconds)
    end
  end
end
