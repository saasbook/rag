module Graders
  class AutoGrader
    class AutoGrader::NoSuchGraderError < StandardError ; end

    # ==== Attributes

    # textual feedback from the autograder on the student's answer
    attr_accessor :comments
    #  errors running the autograder, if any; else nil
    attr_accessor :errors
    # identifier of question being graded
    attr_accessor :assignment_id
    #  achieved raw score as reported by the underlying grader
    attr_reader :raw_score
    #  the maximum possible raw score as reported by the underlying grader
    attr_reader :raw_max
    #  the maximum allowed duration that a test suite can run on a submission.
    attr_reader :timeout

    protected :raw_score, :raw_max

    # Create a new autograder object, which will grade a student's submission
    # given the submission text, a grading strategy, and grading rules to be
    # used by that strategy.
    # * +assignment_id+ - string identifier for question being graded
    # * +grader+ - grading strategy to use.  Currently only +:rspec_grader+ is
    #   valid.  Raises +AutoGrader::NoSuchGraderError+ if nonexistent strategy
    #   specified.
    # * +submitted_answer+ - a string containing the student's submitted answer,
    #   such as code.
    # * +grading_rules+ - a hash containing the grading options supported by the
    #   chosen grading strategy.  See each strategy's class for what options are
    #   expected or required by that strategy.
    # * +normalize+ - if given, normalize score to this maximum; default 100

    #TODO: FIGURE OUT HOW TO LOAD OTHER AUTOGRADERS IN SMART WAY. PROBABLY SHOULD BE DONE THROUGH EXTERNAL GEMS

    def self.create(submission_path, assignment)
      begin
        autograder = AutoGrader.const_get(assignment.autograder_type).new(assignment, submission_path)
      rescue NameError => e
        raise AutoGrader::NoSuchGraderError, "Can't find grading strategy for #{assignment.autograder_type}"
      end
    end

    def normalized_score(max=100)
      raw_max.zero? ? 0 : (max.to_f * raw_score/raw_max).ceil
    end


    # Grade the given question using the specified grader, strategy, and
    # maximum score. Default method does nothing and leaves a score of 0
    def grade!
    end

    protected

    def run_in_thread_with_sandbox_timeout(grading_func)
      begin
        thr = Thread.new {$SAFE = 3; grading_func}
        thr.join(@timeout)
      rescue SecurityError => err
      end
      thr.status
    end

    # Superclass method to be called by
    def initialize(assignment, submission_path)
      raw_max = assignment.score
    end
  end
end
