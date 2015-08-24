class ParseSymbol < ParseState
  def initialize(lexer, parent = nil)
    super
    STDOUT.puts "STARTING SYMBOL" if $VERBOSE
  end

  def parse_token(token)
    STDOUT.puts "Symbol's token is #{token.class}" if $VERBOSE
    # Consume the next token and stop
    @run = false
    nil
  end
end
