# Counts the number of tokens in each line.
class TokenCounter
  include RubyToken

  attr_reader :current_file

  def initialize
    @files = Hash.new
    @tokens_per_line = Hash.new(0)
    @current_file = ""
  end

  # Mark file to associate with the token count.
  def set_current_file(file)
    @current_file = file
    @tokens_per_line = Hash.new(0)
    @files[@current_file] = @tokens_per_line
  end

  # Iterate through all tracked files, passing the
  # the provided formater the token counts.
  def list_tokens_per_line(formater)
    formater.start_count(@files.size)
    @files.each do |fname, tok_per_line|
      formater.start_file(fname)
      tok_per_line.sort.each do |line,num|
	formater.line_token_count(line,num)
      end
      formater.end_file
    end
  end

  # Count the token for the passed line.
  def count_token(line_no,token)
    case token
    when TkSPACE, TkNL, TkRD_COMMENT
      # Do not count these as tokens
    when TkCOMMENT
      # Ignore this only for comments in a statement?
      # Ignore TkCOLON,TkCOLON2  and operators? like "." etc..
    when TkRBRACK, TkRPAREN, TkRBRACE
      # Ignore the closing of an array/index/hash/paren
      # The opening is counted, but no more.
      # Thus [], () {} is counted as 1 token not 2.
    else
      # may want to filter out comments...
      @tokens_per_line[line_no] += 1
    end
  end

end
