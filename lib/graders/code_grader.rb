class CodeGrader < AutoGrader
  class ::NoSuchSpecError < StandardError ; end
  class ::NoSpecsGivenError < StandardError ; end

  require './lib/rspec_runner.rb'
  
  def initialize(submitted_answer, grading_rules)
    @code = submitted_answer
    @normalized_score = 0
    @comments = ''
    # make sure exactly one of specdir, specfile is given
    @specfile = grading_rules[:spec]
    raise NoSpecsGivenError if @specfile.nil? || @specfile.empty?
    raise NoSuchSpecError, "Specfile #{@specfile} not found" unless File.readable?(@specfile)
  end

  def grade!
    if spec_runner.run
      @comments = @spec_runner.all_output
      @normalized_score = @spec_runner.normalized_score(100)
    else
      @comments = @spec_runner.errors
    end
  end

  private

  def spec_runner
    @spec_runner ||= RspecRunner.new(@code, @specfile)
  end
  
end
