class ParseModule < ParseClass
  def initialize(lexer,parent=nil)
    super(lexer,parent)
    @type_name = "Module"
  end
end
