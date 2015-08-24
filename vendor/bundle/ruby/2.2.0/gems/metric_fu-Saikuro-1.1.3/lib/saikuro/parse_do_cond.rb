class ParseDoCond < ParseCond
  def initialize(lexer,parent=nil)
    super(lexer,parent)
    @looking_for_new_line = true
  end

  # Need to consume the do that can appear at the
  # end of these control structures.
  def parse_token(token)
    if @looking_for_new_line
      if token.is_a?(TkDO)
        nil
      else
        if token.is_a?(TkNL)
          @looking_for_new_line = false
        end
        super(token)
      end
    else
      super(token)
    end
  end

end
