class RspecRunner               # :nodoc:
  require 'rubygems'
  require 'rspec'
  require 'tempfile'
  require 'stringio'

  class ExampleTimeoutError < StandardError ; end

  @@preamble = IO.read(File.join(File.expand_path(File.dirname(__FILE__)), 'rspec_sandbox.rb'))

  attr_reader :total, :passed, :failed, :pending, :output
  def initialize(code, specfile)
    @code = code
    @specs = IO.read(specfile)
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
        # don't put anything before student code, so line numbers are preserved
        file.write(@code)
        # sandbox the code with timeouts
        file.write(@@preamble)
        # the specs that go with this code
        file.write(@specs)
        file.flush
        RSpec::Core::Runner::run([file.path], errs, output)
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
    if @output.force_encoding('us-ascii').encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '?') =~ regex
      @total, @failed, @pending = $1.to_i, $2.to_i, $4.to_i
      @passed = @total - @failed - @pending
    else
      @output << "\nCan't parse output: #{@output_stream}"
    end
  end
end
