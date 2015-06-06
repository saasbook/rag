require 'tempfile'
require './lib/edx_client'
require './lib/edx_controller'

Given(/^a configuration file with a grace period of "(.*?)" days? and a late period of "(.*?)" days? and an assignment date of "(.*?)"/) do |graceDays,lateDays, dueDate|
  dueDate = DateTime.parse dueDate # 20131010235959
  file = File.open('config/test_autograders.yml',"w")
  file.write %Q{
  assign-0-queue:
    name: "test-pull"
    type: WeightedRspecGrader
    due : #{dueDate.strftime '%Y%m%d%H%M%S'}
    grace_period: #{graceDays}
    late_period: #{lateDays}
    parts:
      assign-0-part-1:
        uri: ./spec/fixtures/ruby_intro_part1_spec.rb
        type: WeightedRspecGrader
  }

  file.flush
  @codefile = file.path

  file = File.open('config/test_conf.yml', "w")
  file.write %Q{
    live:
      queue_uri: 'uri'
      autograders_yml: ./config/test_autograders.yml
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

Given /^a simple cucumber submission containing a cuke "(.*)", step "(.*)" grade it with mutation file "(.*)"$/ do |cucumber_code, cucumber_steps, mutation_yml|
  # rag/grade3 -a solutions/rottenpotatoes <student_solution>.tar.gz rag/hw3.yml
  create_step_folder_command = "mkdir -p /tmp/features/step_definitions"
  create_folder_output = `#{create_step_folder_command}`
  File.open('/tmp/features/test.feature','w') do |file|
    file.write %Q{#{cucumber_code}}.gsub(',',"\n")
  end
  File.open('/tmp/features/step_definitions/test_steps.rb','w') do |file|
    file.write %Q{#{cucumber_steps}}.gsub(',',"\n")
  end
  archive_command = "tar czf /tmp/features.tar.gz -C /tmp/ features/"
  archive_output = `#{archive_command}`
  `mkdir -p /tmp/db/ /tmp/log/`
  `touch /tmp/db/test.sqlite3`
  command = "ruby ./grade3 -a /tmp/ /tmp/features.tar.gz #{mutation_yml}"
  @feature_output = `#{command}`
  # lacks 'END cucumber comments' if /tmp/log/ not exist
  @feature_output.should =~ /(Tests? passed.*?END cucumber comments.*?)\n/m
  create_remove_command = "rm -rf /tmp/features"
  create_folder_output = `#{create_remove_command}`
  create_remove_command = "rm /tmp/features.tar.gz"
  create_folder_output = `#{create_remove_command}`
end

When(/^I run a WeightedRspecGrader$/) do
  # equivalent to ./new_grader -t WeightedRspecGrader spec/fixtures/correct_example.rb spec/fixtures/correct_example.spec.rb
  args = ['-t', 'WeightedRspecGrader','spec/fixtures/correct_example.rb','spec/fixtures/correct_example.spec.rb']
  @cli_output = Grader.cli(args)
end

Then(/^it should have the expected output$/) do
  @cli_output.should =~ AutoGraderSubprocess::COMMENT_REGEX
end

