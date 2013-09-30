require 'tempfile'

Given(/^The solution file "(.*?)"$/) do |solution_file|

  f = File.open("#{$APP}/#{solution_file}")
  solution_text = f.read
  f.close
  testable_solution = Tempfile.new('solution')
  testable_solution.write(solution_text)
  testable_solution.flush
  @solution_path = testable_solution.path
end

Given(/^The spec file "(.*)"$/) do |spec_file|
  f = File.open("#{$APP}/#{spec_file}")
  spec_text = f.read
  f.close
  testable_spec = Tempfile.new('spec')
  testable_spec.write(spec_text)
  testable_spec.flush
  @spec_path = testable_spec.path
end

When(/^I run the local_autograder with "(.*)"$/) do |grader_type|
  @output = `#{$APP}/run_local_autograder #{@solution_path} #{@spec_path} #{grader_type}`
end

Then(/^the message should match \/(.*)\/$/) do |regexp|
  @output.should match(regexp)
end

Then(/^the score should be (.*)$/) do |score|
  @output.should match(/Score: #{score}/)
end
