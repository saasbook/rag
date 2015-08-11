require 'fileutils'
require 'tempfile'
require 'optparse'

options = {}
OptionParser.new do |opts|
  options = opts
  opts.banner = "Usage: example.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
end.parse!

unless ARGV.count == 1
  puts options
  puts "ARGV #{ARGV}"
  exit 1
end

def put_points(spec_path)
  t_file = Tempfile.new('filename_temp.txt')
  File.open(spec_path, 'r') do |f|
    f.each_line do |line|
      if line !~ /points:/ and line =~ /\[(\d+) points?\]/
        line.delete!("\n")
        temp = line.split('do').insert(-1, ", points: " + $1 + " do").join("")
        t_file.puts temp
      else
        t_file.puts line
      end
    end
  end
  t_file.close
  FileUtils.mv(t_file.path, spec_path)
  return "success!"
end

put_points(ARGV[0])