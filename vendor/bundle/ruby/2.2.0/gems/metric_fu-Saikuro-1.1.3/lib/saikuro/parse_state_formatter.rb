class ParseStateFormater < BaseFormater

  def start(new_out=nil)
    reset_data
    @out = new_out if new_out
  end

  def end
  end

  def start_class_compute_state(type_name,name,complexity,lines)
    @current = name
    @out.puts "-- START #{name} --"
    @out.puts "Type:#{type_name} Name:#{name} Complexity:#{complexity} Lines:#{lines}"
  end

  def end_class_compute_state(name)
    @out.puts "-- END #{name} --"
  end

  def def_compute_state(name,complexity,lines)
    return if @filter.ignore?(complexity)
    warn_error?(complexity, name)
    @out.puts "Type:Def Name:#{name} Complexity:#{complexity} Lines:#{lines}"
  end

end
