class ParseClass < EndableParseState
  def initialize(lexer,parent=nil)
    super(lexer,parent)
    @type_name = "Class"
  end

  def do_constant_token(token)
    @name = token.name if @name.empty?
    nil
  end

  def compute_state(formater)
    # Seperate the Module and Class Children out
    cnm_children, @children = @children.partition do |child|
      child.kind_of?(ParseClass)
    end

    formater.start_class_compute_state(@type_name,@name,self.calc_complexity,self.calc_lines)
    super(formater)
    formater.end_class_compute_state(@name)

    cnm_children.each do |child|
      child.name = @name + "::" + child.name
      child.compute_state(formater)
    end
  end
end
