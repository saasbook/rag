module ResultIndexGenerator
  def summarize_errors_and_warnings(enw, header)
    return "" if enw.empty?
    f = StringIO.new
    erval = Hash.new { |h,k| h[k] = Array.new }
    wval = Hash.new { |h,k| h[k] = Array.new }

    enw.each do |fname, warnings, errors|
      errors.each do |c,m,v|
        erval[v] << [fname, c, m]
      end
      warnings.each do |c,m,v|
        wval[v] << [fname, c, m]
      end
    end

    f.puts "<h2 class=\"class_name\">Errors and Warnings</h2>"
    f.puts "<table width=\"100%\" border=\"1\">"
    f.puts header

    f.puts print_summary_table_rows(erval, "error")
    f.puts print_summary_table_rows(wval, "warning")
    f.puts "</table>"

    f.string
  end

  def print_summary_table_rows(ewvals, klass_type)
    f = StringIO.new
    ewvals.sort { |a,b| b <=> a}.each do |v, vals|
      vals.sort.each do |fname, c, m|
        f.puts "<tr><td><a href=\"./#{fname}\">#{c}</a></td><td>#{m}</td>"
        f.puts "<td class=\"#{klass_type}\">#{v}</td></tr>"
      end
    end
    f.string
  end

  def list_analyzed_files(files)
    f = StringIO.new
    f.puts "<h2 class=\"class_name\">Analyzed Files</h2>"
    f.puts "<ul>"
    files.each do |fname, warnings, errors|
      readname = fname.split("_")[0...-1].join("_")
      f.puts "<li>"
      f.puts "<p class=\"file_name\"><a href=\"./#{fname}\">#{readname}</a>"
      f.puts "</li>"
    end
    f.puts "</ul>"
    f.string
  end

  def write_index(files, filename, title, header)
    return if files.empty?

    File.open(filename,"w") do |f|
      f.puts "<html><head><title>#{title}</title></head>"
      f.puts "#{HTMLStyleSheet.style_sheet}\n<body>"
      f.puts "<h1>#{title}</h1>"

      enw = files.find_all { |fn,w,e| (!w.empty? || !e.empty?) }

      f.puts summarize_errors_and_warnings(enw, header)

      f.puts "<hr/>"
      f.puts list_analyzed_files(files)
      f.puts "</body></html>"
    end
  end

  def write_cyclo_index(files, output_dir)
    header = "<tr><th>Class</th><th>Method</th><th>Complexity</th></tr>"
    write_index(files,
                "#{output_dir}/index_cyclo.html",
                "Index for cyclomatic complexity",
                header)
  end

  def write_token_index(files, output_dir)
    header = "<tr><th>File</th><th>Line #</th><th>Tokens</th></tr>"
    write_index(files,
                "#{output_dir}/index_token.html",
                "Index for tokens per line",
                header)
  end

end
