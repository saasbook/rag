# This file is included before any spec run by autograder, to sandbox the
# tested code in a safe way and enforce timeouts

require 'timeout'
RSpec.configure do |cfg|
  cfg.around(:each) do |ex|
    time_limit = 300
    Timeout::timeout(time_limit, RspecRunner::ExampleTimeoutError) do
      ex.run
    end
  end
end
