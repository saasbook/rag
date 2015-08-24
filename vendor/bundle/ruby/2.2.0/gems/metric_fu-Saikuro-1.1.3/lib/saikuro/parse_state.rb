# Main class and structure used to compute the
# cyclomatic complexity of Ruby programs.
class ParseState
  include RubyToken
  attr_accessor :name, :children, :complexity, :parent, :lines

  @@top_state = nil
  def ParseState.make_top_state()
    @@top_state = ParseState.new(nil)
    @@top_state.name = "__top__"
    @@top_state
  end

  @@token_counter = TokenCounter.new
  def ParseState.set_token_counter(counter)
    @@token_counter = counter
  end
  def ParseState.get_token_counter
    @@token_counter
  end

  def initialize(lexer,parent=nil)
    @name = ""
    @children = Array.new
    @complexity = 0
    @parent = parent
    @lexer = lexer
    @run = true
    # To catch one line def statements, We always have one line.
    @lines = 0
    @last_token_line_and_char = Array.new
  end

  def top_state?
    self == @@top_state
  end

  def lexer=(lexer)
    @run = true
    @lexer = lexer
  end

  def make_state(type,parent = nil)
    cstate = type.new(@lexer,self)
    parent.children<< cstate
    cstate
  end

  def calc_complexity
    complexity = @complexity
    children.each do |child|
      complexity += child.calc_complexity
    end
    complexity
  end

  def calc_lines
    lines = @lines
    children.each do |child|
      lines += child.calc_lines
    end
    lines
  end

  def compute_state(formater)
    if top_state?
      compute_state_for_global(formater)
    end

    @children.each do |s|
      s.compute_state(formater)
    end
  end

  def compute_state_for_global(formater)
    global_def, @children = @children.partition do |s|
      !s.kind_of?(ParseClass)
    end
    return if global_def.empty?
    gx = global_def.inject(0) { |c,s| s.calc_complexity }
    gl = global_def.inject(0) { |c,s| s.calc_lines }
    formater.start_class_compute_state("Global", "", gx, gl)
    global_def.each do |s|
      s.compute_state(formater)
    end
    formater.end_class_compute_state("")
  end

  # Count the tokens parsed if true else ignore them.
  def count_tokens?
    true
  end

  def parse
    while @run do
      tok = @lexer.token
      @run = false if tok.nil?
      if lexer_loop?(tok)
        STDERR.puts "Lexer loop at line : #{@lexer.line_no} char #{@lexer.char_no}."
        @run = false
      end
      @last_token_line_and_char<< [@lexer.line_no.to_i, @lexer.char_no.to_i, tok]
      if $VERBOSE
	puts "DEBUG: #{@lexer.line_no} #{tok.class}:#{tok.name if tok.respond_to?(:name)}"
      end
      @@token_counter.count_token(@lexer.line_no, tok) if count_tokens?
      parse_token(tok)
    end
  end

  # Ruby-Lexer can go into a loop if the file does not end with a newline.
  def lexer_loop?(token)
    return false if @last_token_line_and_char.empty?
    loop_flag = false
    last = @last_token_line_and_char.last
    line = last[0]
    char = last[1]
    ltok = last[2]

    if ( (line == @lexer.line_no.to_i) &&
           (char == @lexer.char_no.to_i) &&
           (ltok.class == token.class) )
      # We are potentially in a loop
      if @last_token_line_and_char.size >= 3
        loop_flag = true
      end
    else
      # Not in a loop so clear stack
      @last_token_line_and_char = Array.new
    end

    loop_flag
  end

  def do_begin_token(token)
    make_state(EndableParseState, self)
  end

  def do_class_token(token)
    make_state(ParseClass,self)
  end

  def do_module_token(token)
    make_state(ParseModule,self)
  end

  def do_def_token(token)
    make_state(ParseDef,self)
  end

  def do_constant_token(token)
    nil
  end

  def do_identifier_token(token)
    if (token.name == "__END__" && token.char_no.to_i == 0)
      # The Ruby code has stopped and the rest is data so cease parsing.
      @run = false
    end
    nil
  end

  def do_right_brace_token(token)
    nil
  end

  def do_end_token(token)
    end_debug
    nil
  end

  def do_block_token(token)
    make_state(ParseBlock,self)
  end

  def do_conditional_token(token)
    make_state(ParseCond,self)
  end

  def do_conditional_do_control_token(token)
    make_state(ParseDoCond,self)
  end

  def do_case_token(token)
    make_state(EndableParseState, self)
  end

  def do_one_line_conditional_token(token)
    # This is an if with no end
    @complexity += 1
    #STDOUT.puts "got IF_MOD: #{self.to_yaml}" if $VERBOSE
    #if state.type != "class" && state.type != "def" && state.type != "cond"
    #STDOUT.puts "Changing IF_MOD Parent" if $VERBOSE
    #state = state.parent
    #@run = false
    nil
  end

  def do_else_token(token)
    STDOUT.puts "Ignored/Unknown Token:#{token.class}" if $VERBOSE
    nil
  end

  def do_comment_token(token)
    make_state(ParseComment, self)
  end

  def do_symbol_token(token)
    make_state(ParseSymbol, self)
  end

  def parse_token(token)
    state = nil
    case token
    when TkCLASS
      state = do_class_token(token)
    when TkMODULE
      state = do_module_token(token)
    when TkDEF
      state = do_def_token(token)
    when TkCONSTANT
      # Nothing to do with a constant at top level?
      state = do_constant_token(token)
    when TkIDENTIFIER,TkFID
      # Nothing to do at top level?
      state = do_identifier_token(token)
    when TkRBRACE
      # Nothing to do at top level
      state = do_right_brace_token(token)
    when TkEND
      state = do_end_token(token)
      # At top level this might be an error...
    when TkDO,TkfLBRACE
      state = do_block_token(token)
    when TkIF,TkUNLESS
      state = do_conditional_token(token)
    when TkWHILE,TkUNTIL,TkFOR
      state = do_conditional_do_control_token(token)
    when TkELSIF #,TkELSE
      @complexity += 1
    when TkELSE
      # Else does not increase complexity
    when TkCASE
      state = do_case_token(token)
    when TkWHEN
      @complexity += 1
    when TkBEGIN
      state = do_begin_token(token)
    when TkRESCUE
      # Maybe this should add complexity and not begin
      @complexity += 1
    when TkIF_MOD, TkUNLESS_MOD, TkUNTIL_MOD, TkWHILE_MOD, TkQUESTION
      state = do_one_line_conditional_token(token)
    when TkNL
      #
      @lines += 1
    when TkRETURN
      # Early returns do not increase complexity as the condition that
      # calls the return is the one that increases it.
    when TkCOMMENT
      state = do_comment_token(token)
    when TkSYMBEG
      state = do_symbol_token(token)
    when TkError
      STDOUT.puts "Lexer received an error for line #{@lexer.line_no} char #{@lexer.char_no}"
    else
      state = do_else_token(token)
    end
    state.parse if state
  end

  def end_debug
    STDOUT.puts "got an end: #{@name} in #{self.class.name}" if $VERBOSE
    if @parent.nil?
      STDOUT.puts "DEBUG: Line #{@lexer.line_no}"
      STDOUT.puts "DEBUG: #{@name}; #{self.class}"
      # to_yaml can cause an infinite loop?
      #STDOUT.puts "TOP: #{@@top_state.to_yaml}"
      #STDOUT.puts "TOP: #{@@top_state.inspect}"

      # This may not be an error?
      #exit 1
    end
  end

end
