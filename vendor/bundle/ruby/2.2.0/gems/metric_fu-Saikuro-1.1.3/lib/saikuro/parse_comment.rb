# Read and consume tokens in comments until a new line.
class ParseComment < ParseState

  # While in a comment state do not count the tokens.
  def count_tokens?
    false
  end

  def parse_token(token)
    if token.is_a?(TkNL)
      @lines += 1
      @run = false
    end
  end
end
