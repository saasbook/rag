require 'tempfile'
require './lib/edx_client'
require './lib/edx_controller'

Given(/^a configuration file with a grace period of "(.*?)" and a late period of "(.*?)" and assignment date of "(.*?)"$/) do |grace, late,duedate|

  generateAutoConfigFile(grace,late,duedate)
end

And(/^a student submits an assignment on "(.*?)" and gets a "(.*?)" days late message$/) do |submission_time, days_late|
  #EdXClient.init_autograders('./config/autograders.yml')
  controller_mock = double("EdXController")
  controller_mock.should_receive(:send_grade_response) do |checkmark, score, comment|
    checkmark.should be_false
    score.should eq 0
    comment.should =~ /^<pre>More than 3 day\(s\) late:/
  end
  EdXController.stub(:new).and_return controller_mock
  code = %Q{
    class MyClass
      def self.my_method
        return 'foo'
      end
    end
  }
  client = EdXClient.new
  client.should_receive(:each_submission).and_yield("assign-0-queue", code, 'assign-0-part-1', {"submission_time" => submission_time, "anonymous_student_id" => "c2b7336d28e9341109bd03b1d041b544" })
  client.run()
  #score, comments =AutoGraderSubprocess.run_autograder_subprocess(submission_path, spec, grader_type)


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


def generateAutoConfigFile (graceDays,lateDays, dueDate)

  file = File.open('config/autograders.yml',"w")
  file.write %Q{
  assign-0-queue:
    name: "test-pull"
    type: WeightedRspecGrader
    due : #{dueDate}
    grace_period: #{graceDays}
    late_period: #{lateDays}
    parts:
      assign-0-part-1:
        uri: ./spec/fixtures/ruby_intro_part1_spec.rb
        type: WeightedRspecGrader
  }

  file.flush
  @codefile = file.path

  file = File.open('config/conf.yml', "w")
  file.write %Q{
    live:
      queue_uri: 'uri'
      autograders_yml: ./config/autograders.yml
      django_auth:
        username: 'username'
        password: 'password'
      user_auth:
        unnecessary: "unnecessary"
        stuff: "stuff"
      user_name: 'username'
      user_pass: 'password'
      halt: false # default: true, exit when all submission queues are empty
      sleep_duration: 30 # default 300, time in seconds to sleep when all queues are empty, only valid when halt == false doesn't matter yet
  }
  file.flush
  @configfile = file.path

end
