Then /^(?:|I )should either be on (.+) or (.+)$/ do |page_name, page_name2|
  begin
    step %Q{I should be on #{page_name2}}
  #rescue Cucumber::Undefined => e
  #  step %Q{I should be on #{page_name2}}
  #rescue
  #  err_msg = $!.to_s
  #  if err_msg =~ /^Can't find mapping from ".*" to a path\.$/
  #    step %Q{I should be on #{page_name2}}
  #  else
  #    raise
  #  end
  rescue
    step %Q{I should be on #{page_name}}
  end
end
