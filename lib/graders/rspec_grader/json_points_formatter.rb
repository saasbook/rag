require 'rspec/core/formatters/base_formatter'
require 'json'
module RSpec
  module Core
    module Formatters
      class JsonPointsFormatter < JsonFormatter
        RSpec::Core::Formatters.register self, :message, :dump_summary, :dump_profile, :stop, :close
        
        private

        def format_example(example)
          {
            description: example.description,
            points: example.metadata[:points] || 0,
            status: example.execution_result.status.to_s,
            pending_message: example.execution_result.pending_message
          }
        end
      end
    end
  end
end
