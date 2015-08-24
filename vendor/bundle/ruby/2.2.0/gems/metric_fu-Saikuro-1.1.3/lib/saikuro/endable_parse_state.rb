class EndableParseState < ParseState
  def initialize(lexer,parent=nil)
    super(lexer,parent)
    STDOUT.puts "Starting #{self.class}" if $VERBOSE
  end

  def do_end_token(token)
    end_debug
    @run = false
    nil
  end
end
