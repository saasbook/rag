class RspecGrader < AutoGrader
  class RspecGrader::NoSuchSpecError < StandardError ; end
  class RspecGrader::NoSpecsGivenError < StandardError ; end

  # The constructor is called from +AutoGrader.create+ so you shouldn't call
  # it directly.  The required and optional grading rules for
  # +RspecGrader+ are:
  # * +:spec+ - the full pathname to a specfile that will be run
  #   against the student's code.  The spec should <b>not</b> try to
  #   +require+ or +include+ the subject code file, but it can +require+
  #   or +include+ any other Ruby libraries needed for the specs to run.

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
