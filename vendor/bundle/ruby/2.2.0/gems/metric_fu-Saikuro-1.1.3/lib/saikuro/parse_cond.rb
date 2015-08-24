class ParseCond < EndableParseState
  def initialize(lexer,parent=nil)
    super(lexer,parent)
    @complexity = 1
  end
end
