
# class String
#   include Term::ANSIColor
# end

class Hash
  # Returns a new +Hash+ containing +to_s+ed keys and values from this +Hash+.

  def envify
    h = {}
    self.each_pair { |k,v| h[k.to_s] = v.to_s }
    return h
  end
end


