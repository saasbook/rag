class BaseFormater
  attr_accessor :warnings, :errors, :current

  def initialize(out, filter = nil)
    @out = out
    @filter = filter
    reset_data
  end

  def warn_error?(num, marker)
    klass = ""

    if @filter.error?(num)
      klass = ' class="error"'
      @errors<< [@current, marker, num]
    elsif @filter.warn?(num)
      klass = ' class="warning"'
      @warnings<< [@current, marker, num]
    end

    klass
  end

  def reset_data
    @warnings = Array.new
    @errors = Array.new
    @current = ""
  end

end
