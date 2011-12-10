class CodeGrader < AutoGrader
  class ::NoSuchSpecError < StandardError ; end
  class ::NoSpecsGivenError < StandardError ; end

  require './lib/rspec_runner.rb'
  
  def initialize(submitted_answer, grading_rules)
    @code = submitted_answer
    @raw_score = @raw_max = 0
    @comments = ''
    # make sure exactly one of specdir, specfile is given
    @specfile = grading_rules[:spec]
    raise NoSpecsGivenError if @specfile.nil? || @specfile.empty?
    raise NoSuchSpecError, "Specfile #{@specfile} not found" unless File.readable?(@specfile)
  end

  def grade!
    runner =  RspecRunner.new(@code, @specfile)
    runner.run
    @raw_score = runner.passed
    @raw_max = runner.total
    @comments = runner.output
  end

end
