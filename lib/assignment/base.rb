
require_relative '../rag_logger'
module Assignment
  # this class contains both the assignment info extracted from grader_payload
  # as well as the submission itself. Any adapter should be able to grade this
  # type of submission and return a response.
  class Base
    include RagLogger
    include ActiveModel::Validations
    attr_reader :due_date, :assignment_name, :assignment_spec_file,  :autograder_type, :score
    validates_presence_of :due_date, :assignment_name, :assignment_spec_file, :autograder_type

    def initialize(_submission)
      raise "abstract method"
    end

    # default behavior is not to adjust lateness policy. Can be overridden by subclass
    def apply_lateness!(_submission)
    end

    def fetch_spec_file(spec_uri)
    end
  end
end
