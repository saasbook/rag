require 'rspec/core/formatters/base_formatter'
require 'json'
module RSpec
  module Core
    module Formatters
      class JsonPointsFormatter < JsonFormatter
        RSpec::Core::Formatters.register self, :message, :dump_summary, :dump_profile, :stop

        def stop(notification)
          @output_hash[:examples] = notification.examples.map do |example|
            format_example(example)
          end
        end

        def close(_notification)
        end
        
        private

        def format_example(example)
          {
            description: example.description,
            points: example.metadata[:points] || 1,
            status: example.execution_result.status.to_s,
            pending_message: example.execution_result.pending_message
          }
        end
      end
    end
  end
end
