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
    @run_spec = RspecRunner.new(@code, @specfile)
    @run_spec.run
    @comments = @run_spec.all_output
    @normalized_score = @run_spec.normalized_score(100)
  end

  private

  def run_specs
    error_stream = StringIO.new('', 'w')
    output_stream = StringIO.new("OUTPUT:\n", 'w')
    file = Tempfile.open(["rspec-#{question_id}", '.rb'])
    file.write(@code)
    file.close
    config = RSpec::configuration
    RSpec::configuration.requires = [file.path]
    RSpec::configuration.files_to_run = @specfile
    puts "Files = #{@specfile} for #{file.path}"
    debugger
    #RSpec::Core::Runner::run(@@rspec_options, error_stream, output_stream)
    RSpec::Core::Runner::run(['--require', file.path, @specfile], error_stream, output_stream)
    @comments << ([error_stream, output_stream].join "\n\n")
  end
end
