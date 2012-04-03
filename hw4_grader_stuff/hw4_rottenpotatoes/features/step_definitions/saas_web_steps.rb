Then /^(?:|I )should either be on (.+) or (.+)$/ do |page_name, page_name2|
  current_path = URI.parse(current_url).path
  paths = [path_to(page_name), path_to(page_name2)]
  if current_path.respond_to? :should
    paths.should include current_path
  else
    assert paths.include?(current_path)
  end
end
