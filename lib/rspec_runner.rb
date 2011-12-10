class RspecRunner
  require 'rubygems'
  require 'rspec'
  require 'tempfile'
  require 'stringio'
  @@rspec_options = ''
  
  attr_reader :total, :passed, :failed, :pending, :errors
  def initialize(code, specfile)
    @errors = nil
    @code = code
    @specfile = specfile
    @total = 0
    @passed = 0
    @failed = 0
    @pending = 0
    @normalized_score = 0
    @error_stream = ''
    @output_stream = ''
  end

  def all_output
    [@error_stream, @output_stream].join("\n****\n")
  end

  def run
    @output_stream, @error_stream = run_rspec
    parse_stats
  end

  def normalized_score(max=100)
    @total.zero? ? 0 : (max.to_f * @passed/@total).ceil
  end

  private

  def run_rspec
    errs = StringIO.new('', 'w')
    output = StringIO.new('', 'w')
    Tempfile.open(['rspec', '.rb']) do |file|
      file.write(@code)
      file.flush
      RSpec::Core::Runner::run(['--require', file.path, @specfile], errs, output)
    end
    return errs.string, output.string
  end
  
  def parse_stats
    regex = /(\d+)\s+examples?,\s+(\d+)\s+failures?(,\s+(\d+)\s+pending)?$/
    if @output_stream =~ regex
      @total, @failed, @pending = $1.to_i, $2.to_i, $4.to_i
      @passed = @total - @failed - @pending
    else
      @errors = "Can't parse output: #{@output_stream}"
    end
  end
end
