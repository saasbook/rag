require 'rspec/core/formatters/base_formatter'
require 'json'

class JsonPointsFormatter < RSpec::Core::Formatters::JsonFormatter
  private
  def format_example(example)
    {
      description: example.description,
      full_description: example.full_description,
      points: example.metadata[:points] || 1,
      status: example.execution_result.status.to_s,
      file_path: example.metadata[:file_path],
      line_number: example.metadata[:line_number],
      run_time: example.execution_result.run_time,
      pending_message: example.execution_result.pending_message
    }
  end
end