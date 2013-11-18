require 'tempfile'


Given(/^a configuration file with a grace period of "(.*?)" and a late period of "(.*?)" and assignment date of "(.*?)"$/) do |grace, late,duedate|

  generateAutoConfigFile(grace,late,duedate)
end

And(/^a student submits an assignment "(.*?)" days late$/) do |days|
  EdXClient.init_autograders('./config/autograders.yml')
  #client = EdXClient.new()

  file = Tempfile.new('test-submission')
  file.write %Q{
    class MyClass
      def self.my_method
        #{code}
        return 'foo'
      end
    end
  }
  file.flush
  submission_path = file.path


  score, comments =AutoGraderSubprocess.run_autograder_subprocess(submission_path, spec, grader_type)

  client.
  #submitted_date=Date.today+days
  # @output=""


end




Given /^a submission containing "(.*)"$/ do |code|
  file = Tempfile.new('cucumber-code')
  file.write %Q{
    class MyClass
      def self.my_method
        #{code}
        return 'foo'
      end
    end
}
  file.flush
  @codefile = file.path
end
Given /^a simple ruby submission containing "(.*)"$/ do |code|
  file = Tempfile.new('cucumber-code')
  file.write %Q{
        #{code}
}
  file.flush
  @codefile = file.path
end
When /^I run the generic RSpec grader$/ do
  specfile = Tempfile.new('cucumber-spec')
  specfile.write %Q{
    describe MyClass do
      it 'should be safe' do
        MyClass.my_method.should == 'foo'
      end
    end
}
  specfile.flush
  @specfile = specfile.path
  @output = `ruby #{$APP}/grade #{@codefile} #{@specfile}`
end

Then /^the message should match \/(.*)\/$/ do |regexp|
  @output.should match(regexp)
end

Then /^the "(.*)" section should contain "(.*)"$/ do |section, str|
  @output.should include(str)
end

When /^I run the ruby intro grader for "(.*?)"$/ do |homework_number|


  case  homework_number

    when "HW0-1"
      specfile = './spec/fixtures/ruby_intro_part1_spec.rb'
    when "HW0-2"
      specfile= './spec/fixtures/ruby_intro_part2_spec.rb'
    when "HW0-3"
      specfile= './spec/fixtures/ruby_intro_part3_spec.rb'
  end

  @output = `ruby #{$APP}/grade #{@codefile} #{specfile}`
end


def generateAutoConfigFile (graceDays,lateDays, dueDays)


  due_date = Date.today.strftime("%Y%m%d%H%M%S")

  file = File.open('config/autograders.yml',"w")
  file.write %Q{
  assign-0-queue:
  name: "test-pull"
  type: WeightedRspecGrader
  due : #{due_date}
  grace_period: #{graceDays}
  late_period: #{lateDays}
  parts:
    assign-0-part-1:
      uri: ../hw/solutions/part1_spec.rb
      type: WeightedRspecGrader
  }

  file.flush
  @codefile = file.path

end
