class ParseDef < EndableParseState

  def initialize(lexer,parent=nil)
    super(lexer,parent)
    @complexity = 1
    @looking_for_name = true
    @first_space = true
  end

  # This way I don't need to list all possible overload
  # tokens.
  def create_def_name(token)
    case token
    when TkSPACE
      # mark first space so we can stop at next space
      if @first_space
	@first_space = false
      else
	@looking_for_name = false
      end
    when TkNL,TkLPAREN,TkfLPAREN,TkSEMICOLON
      # we can also stop at a new line or left parenthesis
      @looking_for_name = false
    when TkDOT
      @name<< "."
    when TkCOLON2
      @name<< "::"
    when TkASSIGN
      @name<< "="
    when TkfLBRACK
      @name<< "["
    when TkRBRACK
      @name<< "]"
    else
      begin
	@name<< token.name.to_s
      rescue Exception => err
	#what is this?
	STDOUT.puts @@token_counter.current_file
	STDOUT.puts @name
	STDOUT.puts token.inspect
	STDOUT.puts err.message
	exit 1
      end
    end
  end

  def parse_token(token)
    if @looking_for_name
      create_def_name(token)
    end
    super(token)
  end

  def compute_state(formater)
    formater.def_compute_state(@name, self.calc_complexity, self.calc_lines)
    super(formater)
  end
end
