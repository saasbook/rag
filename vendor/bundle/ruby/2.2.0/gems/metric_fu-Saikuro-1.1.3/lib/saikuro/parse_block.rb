class ParseBlock < EndableParseState

  def initialize(lexer,parent=nil)
    super(lexer,parent)
    @complexity = 1
    @lbraces = Array.new
  end

  # Because the token for a block and hash right brace is the same,
  # we need to track the hash left braces to determine when an end is
  # encountered.
  def parse_token(token)
    if token.is_a?(TkLBRACE)
      @lbraces.push(true)
    elsif token.is_a?(TkRBRACE)
      if @lbraces.empty?
        do_right_brace_token(token)
        #do_end_token(token)
      else
        @lbraces.pop
      end
    else
      super(token)
    end
  end

  def do_right_brace_token(token)
    # we are done ? what about a hash in a block :-/
    @run = false
    nil
  end

end
