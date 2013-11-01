class Hash

  def convert_keys(converter=nil)
    converter ||= lambda {|x|x.to_sym}
    self.class.send :convert_keys, self, converter
  end

  class << self
    private
    def convert_keys(h, converter)
      return h unless h.is_a? Hash
      new_h = h.dup

      h.each_key do |k|
        v = new_h.delete(k)
        new_h[converter.call(k)] = convert_keys(v, converter)
      end

      h.replace(new_h)
    end
  end

end
