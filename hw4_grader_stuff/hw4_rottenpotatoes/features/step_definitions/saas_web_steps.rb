Then /^(?:|I )should either be on (.+) or (.+)$/ do |page_name, page_name2|
  current_path = URI.parse(current_url).path
  current_path.should satisfy{|s| [path_to(page_name), path_to(page_name2)].include? s}
end
