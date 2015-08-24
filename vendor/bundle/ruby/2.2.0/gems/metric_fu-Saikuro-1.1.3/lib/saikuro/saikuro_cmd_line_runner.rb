class SaikuroCMDLineRunner
  require 'stringio'
  require 'getoptlong'
  require 'fileutils'
  require 'find'

  include ResultIndexGenerator

  attr_accessor :formater, :output_dir, :comp_state, :comp_token,
    :state_formater, :token_count_formater
  def initialize
    @opt = GetoptLong.new(
                         ["-o","--output_directory", GetoptLong::REQUIRED_ARGUMENT],
                         ["-h","--help", GetoptLong::NO_ARGUMENT],
                         ["-f","--formater", GetoptLong::REQUIRED_ARGUMENT],
                         ["-c","--cyclo", GetoptLong::NO_ARGUMENT],
                         ["-t","--token", GetoptLong::NO_ARGUMENT],
                         ["-y","--filter_cyclo", GetoptLong::REQUIRED_ARGUMENT],
                         ["-k","--filter_token", GetoptLong::REQUIRED_ARGUMENT],
                         ["-w","--warn_cyclo", GetoptLong::REQUIRED_ARGUMENT],
                         ["-s","--warn_token", GetoptLong::REQUIRED_ARGUMENT],
                         ["-e","--error_cyclo", GetoptLong::REQUIRED_ARGUMENT],
                         ["-d","--error_token", GetoptLong::REQUIRED_ARGUMENT],
                         ["-p","--parse_file", GetoptLong::REQUIRED_ARGUMENT],
                         ["-i","--input_directory", GetoptLong::REQUIRED_ARGUMENT],
                         ["-v","--verbose", GetoptLong::NO_ARGUMENT]
                         )
    self.output_dir = "./"
    self.formater = "html"
    self.comp_state = self.comp_token = false
  end

  def get_ruby_files(path)
    files = Array.new
    Find.find(path) do |f|
      if !FileTest.directory?(f)
	if f =~ /rb$/
	  files<< f
	end
      end
    end
    files
  end

  def run
    files = Array.new
    state_filter = Filter.new(5)
    token_filter = Filter.new(10, 25, 50)

    parse_opts(state_filter, token_filter, files)
    set_formatters(state_filter, token_filter)

    idx_states, idx_tokens = analyze(files)
    write_results(idx_states, idx_tokens)
  end

  def analyze(files)
    Saikuro.analyze(files,
      state_formater,
      token_count_formater,
      output_dir)
  end

  def write_results(idx_states, idx_tokens)
    write_cyclo_index(idx_states, output_dir)
    write_token_index(idx_tokens, output_dir)
  end

  def parse_opts(state_filter, token_filter, files)
    @opt.each do |arg,val|
      case arg
      when "-o"  then self.output_dir = val
      when "-h"  then usage('help')
      when "-f"  then self.formater = val
      when "-c"  then self.comp_state = true
      when "-t"  then self.comp_token = true
      when "-k"  then token_filter.limit = val.to_i
      when "-s"  then token_filter.warn = val.to_i
      when "-d"  then token_filter.error = val.to_i
      when "-y"  then state_filter.limit = val.to_i
      when "-w"  then state_filter.warn = val.to_i
      when "-e"  then state_filter.error = val.to_i
      when "-p"  then files<< val
      when "-i"  then files.concat(get_ruby_files(val))
      when "-v"
        STDOUT.puts "Verbose mode on"
        $VERBOSE = true
      end
    end
    usage('no complexity token or state set') if no_complexity_token_or_state?
  rescue => err
    usage([err.class,err.message,err.backtrace[0..15]].join(', '))
  end

  def usage(message)
usage = <<-USAGE
== Usage

saikuro [ -h ] [-o output_directory] [-f type] [ -c, -t ]
[ -y, -w, -e, -k, -s, -d - number ] ( -p file | -i directory )

== Help

-o, --output_directory (directory) : A directory to ouput the results in.
The current directory is used if this option is not passed.

-h, --help : This help message.

-f, --formater (html | text) : The format to output the results in.
The default is html

-c, --cyclo : Compute the cyclomatic complexity of the input.

-t, --token : Count the number of tokens per line of the input.

-y, --filter_cyclo (number) : Filter the output to only include methods
whose cyclomatic complexity are greater than the passed number.

-w, --warn_cyclo (number) : Highlight with a warning methods whose
cyclomatic complexity are greather than or equal to the passed number.


-e, --error_cyclo (number) : Highligh with an error methods whose
cyclomatic complexity are greather than or equal to the passed number.


-k, --filter_token (number) : Filter the output to only include lines
whose token count are greater than the passed number.


-s, --warn_token (number) : Highlight with a warning lines whose
token count are greater than or equal to the passed number.


-d, --error_token (number) : Highlight with an error lines whose
token count are greater than or equal to the passed number.


-p, --parse_file (file) : A file to use as input.

-i, --input_directory (directory) : All ruby files found recursively
inside the directory are passed as input.
USAGE
  STDOUT.puts usage
  STDOUT.puts
  STDOUT.puts message
  end

  def no_complexity_token_or_state?
    !comp_state && !comp_token
  end

  def set_formatters(state_filter, token_filter)
    if formater =~ /html/i
      self.state_formater = StateHTMLComplexityFormater.new(STDOUT,state_filter)
      self.token_count_formater = HTMLTokenCounterFormater.new(STDOUT,token_filter)
    else
      self.state_formater = ParseStateFormater.new(STDOUT,state_filter)
      self.token_count_formater = TokenCounterFormater.new(STDOUT,token_filter)
    end

    self.state_formater = nil if !comp_state
    self.token_count_formater = nil if !comp_token
  end

end
