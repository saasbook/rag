Then /^(?:|I )should either be on (.+) or (.+)$/ do |page_name, page_name2|
  begin
    step %Q{I should be on #{page_name2}}
  rescue Cucumber::Undefined => e
    step %Q{I should be on #{page_name}}
  end
end
