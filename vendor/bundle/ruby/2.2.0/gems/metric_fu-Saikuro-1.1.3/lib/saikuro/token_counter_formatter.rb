class TokenCounterFormater < BaseFormater

  def start(new_out=nil)
    reset_data
    @out = new_out if new_out
    @out.puts "Token Count"
  end

  def start_count(number_of_files)
    @out.puts "Counting tokens for #{number_of_files} files."
  end

  def start_file(file_name)
    @current = file_name
    @out.puts "File:#{file_name}"
  end

  def line_token_count(line_number,number_of_tokens)
    return if @filter.ignore?(number_of_tokens)
    warn_error?(number_of_tokens, line_number)
    @out.puts "Line:#{line_number} ; Tokens : #{number_of_tokens}"
  end

  def end_file
    @out.puts ""
  end

  def end_count
  end

  def end
  end

end

