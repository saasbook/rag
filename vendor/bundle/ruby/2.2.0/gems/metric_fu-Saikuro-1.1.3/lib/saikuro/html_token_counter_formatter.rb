class HTMLTokenCounterFormater < TokenCounterFormater
  include HTMLStyleSheet

  def start(new_out=nil)
    reset_data
    @out = new_out if new_out
    @out.puts "<html>"
    @out.puts style_sheet
    @out.puts "<body>"
  end

  def start_count(number_of_files)
    @out.puts "<div class=\"start_token_count\">"
    @out.puts "Number of files: #{number_of_files}"
    @out.puts "</div>"
  end

  def start_file(file_name)
    @current = file_name
    @out.puts "<div class=\"file_count\">"
    @out.puts "<p class=\"file_name\">"
    @out.puts "File: #{file_name}"
    @out.puts "</p>"
    @out.puts "<table width=\"100%\" border=\"1\">"
    @out.puts "<tr><th>Line</th><th>Tokens</th></tr>"
  end

  def line_token_count(line_number,number_of_tokens)
    return if @filter.ignore?(number_of_tokens)
    klass = warn_error?(number_of_tokens, line_number)
    @out.puts "<tr><td>#{line_number}</td><td#{klass}>#{number_of_tokens}</td></tr>"
  end

  def end_file
    @out.puts "</table>"
  end

  def end_count
  end

  def end
    @out.puts "</body>"
    @out.puts "</html>"
  end
end
