def escape_all_fields(str)
  chomped_str = str.chomp
  split_str = chomped_str.split
  split_str.map! {|x| '"' + x + '"'}
  split_str.join(" ")
end
