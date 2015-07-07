class RspecRunner               # :nodoc:
  require 'rubygems'
  require 'rspec'
  require 'tempfile'
  require 'stringio'
  require 'json'

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
    temp = run_rspec
    @output = temp[0] # or #{JSON.parse(temp[1])["examples"]} to avoid parsing with
    object_json = JSON.parse(temp[1])["summary"]
    return if object_json.nil? && object_json["example_count"].nil?
    @total = object_json["example_count"]
    @failed = object_json["failure_count"]
    @pending = object_json["pending_count"]
    @passed = @total - @failed - @pending
  end

  private

  def run_rspec
    ## TODO: USE THE JSON FORMATTER TO COMPUTE SECORES AND STUFF; LESS FRAGILE
    errs = StringIO.new('', 'w')
    output = StringIO.new('', 'w')
    errsJSON = StringIO.new('', 'w')
    outputJSON = StringIO.new('', 'w')
    tempfilepath = ''
    Tempfile.open(['rspec', '.rb']) do |file|
      begin
        # don't put anything before student code, so line numbers are preserved
        file.write(@code)
        # sandbox the code with timeouts
        file.write(@@preamble)
        # the specs that go with this code
        file.write(@specs)
        file.flush
        tempfilepath = file.path
        ### just in case config changes at some point but it doesn't change
        # orig_config = RSpec.configuration.clone
        RSpec::Core::Runner.run([tempfilepath, "-fdocumentation"], errs, output)
        RSpec.reset
        # RSpec.configuration = orig_config
        RSpec::Core::Runner.run([tempfilepath, "-fjson"], errsJSON, outputJSON)
      rescue Exception => e
        # if tmpfile name appears in err msg, replace with 'your_code.rb' to be friendly
        output.string << e.message.gsub(file.path, 'your_code.rb')
        @errors = true
      end
    end
    return [output.string, errs.string].join("\n"),outputJSON.string
  end

end
