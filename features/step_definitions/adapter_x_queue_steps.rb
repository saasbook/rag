require 'tempfile'
require './lib/edx_client'
require './lib/edx_controller'

Given(/^an XQueue that has submission "(.*?)" in queue"/) do |submission|
  
end

And(/^a student submits an assignment on "(.*?)" and gets a "(.*?)" period message$/) do |submission_time, period|
  #EdXClient.init_autograders('./config/autograders.yml')
  submission_time = DateTime.parse submission_time
  message = case period
    when "no late period credit"
      /^<pre>More than \d+ day\(s\) late:/
    when "no credit"
      /^<pre>More than \d+ day\(s\) late:/
    when "grace"
      /^<pre>Late assignment: score scaled by .75/
    when "late"
      /^<pre>It's less than \d+ day\(s\) late: score scaled by: .5/
    when "on time"
      /^<pre>On Time/
    else
      /^Something not likely to be in the message/
  end
  controller_mock = double("EdXController")
  controller_mock.should_receive(:send_grade_response) do |checkmark, score, comment|
    checkmark.should be_false
    score.should eq 0
    comment.should =~ message
  end
  EdXController.stub(:new).and_return controller_mock
  code = %Q{
    class MyClass
      def self.my_method
        return 'foo'
      end
    end
  }
  client = EdXClient.new nil, 'config/test_conf.yml'
  client.should_receive(:each_submission).and_yield("assign-0-queue", code, 'assign-0-part-1', {"submission_time" => submission_time.strftime('%Y%m%d%H%M%S'), "anonymous_student_id" => "c2b7336d28e9341109bd03b1d041b544" })
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
