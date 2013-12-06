require 'ruby-debug'

class AutoGrader
  class AutoGrader::NoSuchGraderError < StandardError ; end

  if not defined? @@initialized
    # Dir["lib/graders/*_grader/*.rb"].each { |file| load file }
    load "lib/graders/rspec_grader/rspec_sandbox.rb"
    load "lib/graders/rspec_grader/rspec_runner.rb"
    load "lib/graders/rspec_grader/rspec_grader.rb"
    load "lib/graders/rspec_grader/weighted_rspec_grader.rb"
    load "lib/graders/rspec_grader/github_rspec_grader.rb"
    load "lib/graders/rspec_grader/heroku_rspec_grader.rb"
    load "lib/graders/rspec_grader/hw5_grader.rb"
    load "lib/graders/beautiful_code_grader/beautiful_code_grader.rb"
    load "lib/graders/migration_grader/migration_grader.rb"
    load "lib/graders/multiple_choice_grader/multiple_choice_grader.rb"
    load "lib/graders/feature_grader/feature_grader.rb"
    load "lib/graders/feature_grader/hw3_grader.rb"
    load "lib/graders/feature_grader/hw4_grader.rb"
    @@initialized = true
  end

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

  def self.create(assignment_id, grader, submitted_answer, grading_rules, normalize=100)
    #@@initialized ||= AutoGrader.class_init
    if submitted_answer.nil? || submitted_answer.empty?
      AutoGrader.new(assignment_id)
    else
      begin
        obj = Object.const_get(grader).send(:new, submitted_answer, grading_rules)
        obj.assignment_id = assignment_id
        return obj
      rescue NameError => e
        raise AutoGrader::NoSuchGraderError, "Can't find grading strategy for #{grader}"
      end
    end
  end

  def normalized_score(max=100)
    raw_max.zero? ? 0 : (max.to_f * raw_score/raw_max).ceil
  end


  # Grade the given question using the specified grader, strategy, and
  # maximum score.  If all
  def grade!
    # default method does nothing and leaves a score of 0
  end

  private

  def self.class_init
    #Dir["lib/graders/*_grader/*.rb"].each { |file| load file }
    # load "lib/graders/rspec_grader/rspec_sandbox.rb"
    # load "lib/graders/rspec_grader/rspec_runner.rb"
    # load "lib/graders/rspec_grader/rspec_grader.rb"
    # load "lib/graders/rspec_grader/weighted_rspec_grader.rb"
    # load "lib/graders/rspec_grader/github_rspec_grader.rb"
    # load "lib/graders/rspec_grader/hw5_grader.rb"
    # load "lib/graders/rspec_grader/heroku_rspec_grader.rb"
    # load "lib/graders/beautiful_code_grader/beautiful_code_grader.rb"
    # load "lib/graders/migration_grader/migration_grader.rb"
    # load "lib/graders/multiple_choice_grader/multiple_choice_grader.rb"
    # load "lib/graders/feature_grader/feature_grader.rb"
    # load "lib/graders/feature_grader/hw3_grader.rb"
    # load "lib/graders/feature_grader/hw4_grader.rb"
  end

  #:nodoc: not to be used externally
  private
  def initialize(assignment_id)
    @raw_max = @raw_score = 0
    @comments = 'You did not submit any answer.'
    @assignment_id = assignment_id
    @errors = nil
  end

end

