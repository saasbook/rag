class RspecRunner               # :nodoc:
  require 'rubygems'
  require 'rspec'
  require 'tempfile'
  require 'stringio'

  # array of options for rspec, as they would appear in ARGV; e.g. [--format, 'nested']
  @@rspec_options = []
  
  attr_reader :total, :passed, :failed, :pending, :output
  def initialize(code, specfile)
    @code = code
    @specfile = specfile
    @total = 0
    @passed = 0
    @failed = 0
    @pending = 0
    @output = ''
    @errors = false
  end

  def run
    @output = run_rspec
    parse_stats unless @errors
  end

  private

  def run_rspec
    errs = StringIO.new('', 'w')
    output = StringIO.new('', 'w')
    Tempfile.open(['rspec', '.rb']) do |file|
      begin
        file.write(@code)
        file.flush
        RSpec::Core::Runner::run(['--require', file.path, @specfile], errs, output)
      rescue Exception => e
        # if tmpfile name appears in err msg, replace with 'your_code.rb' to be friendly
        output.string << e.message.gsub(file.path, 'your_code.rb')
        @errors = true
      end
    end
    return [output.string, errs.string].join("\n")
  end
  
  def parse_stats
    regex = /(\d+)\s+examples?,\s+(\d+)\s+failures?(,\s+(\d+)\s+pending)?$/
    if @output =~ regex
      @total, @failed, @pending = $1.to_i, $2.to_i, $4.to_i
      @passed = @total - @failed - @pending
    else
      @output << "\nCan't parse output: #{@output_stream}"
    end
  end
end
