require 'spec_helper'

describe EdXClient do

  context 'when initialized' do

    it "config elements should be set up correctly" do
      conf = {}
      conf['queue_uri'] = 'https://test.com/live-queue'
      conf['autograders_yml'] = './config/autograders.yml'
      conf['user_auth'] = {"user_name"=>"user-name", "user_pass"=>"user-password"}
      conf['django_auth'] = {"username"=>"django-user", "password"=>"django-password"}
      conf['halt'] = false
      conf['sleep_duration'] = 30

      EdXClient.should_receive(:load_configurations).with('live').and_return(conf)

      auto_conf = {'assign-0-queue'=>{}}
      auto_conf['assign-0-queue'][:name] = 'test-pull'
      auto_conf['assign-0-queue'][:type] = 'WeightedRspecGrader'

      EdXClient.should_receive(:init_autograders).with('./config/autograders.yml').and_return(auto_conf)

      client = EdXClient.new('live')
      client.instance_eval{@endpoint}.should == 'https://test.com/live-queue'
      client.instance_eval{@user_auth}.should == ["user-name","user-password"]
      client.instance_eval{@django_auth}.should == ["django-user", "django-password"]
      #client.instance_eval{@autograders}.should == {
      #    'test-assign-1-part-1' => { uri: 'http://test.url/', type: 'WeightedRspecGrader'},
      #}
    end

  end

  it "loads configurations" do
    conf_yml = <<EOF
staging:
  queue_uri: https://test.com/staging-queue
  autograders_yml: ./config/autograders.yml
  django_auth:
    username: 'django-user'
    password: 'django-password'
  user_auth:
    user_name: 'user-name'
    user_pass: 'user-password'
  halt: false # default: true, exit when all submission queues are empty
  sleep_duration: 30 # default 300, time in seconds to sleep when all queues are empty, only valid when halt == false doesn't matter yet

live:
  queue_uri: https://test.com/live-queue
  autograders_yml: ./config/autograders.yml
  django_auth:
    username: 'django-user'
    password: 'django-password'
  user_auth:
    user_name: 'user-name'
    user_pass: 'user-password'
  halt: false # default: true, exit when all submission queues are empty
  sleep_duration: 30 # default 300, time in seconds to sleep when all queues are empty, only valid when halt == false doesn't matter yet
EOF


      File.should_receive(:file?).and_return true
      File.should_receive(:open).with('config/conf.yml','r').and_return(conf_yml)
      conf = EdXClient.load_configurations('live')
      conf['queue_uri'].should eq 'https://test.com/live-queue'
      conf['user_auth'].should eq({"user_name"=>"user-name", "user_pass"=>"user-password"})
      conf['django_auth'].should eq({"username"=>"django-user", "password"=>"django-password"})
      conf['halt'].should be_false
      conf['sleep_duration'].should eq 30
      conf['autograders_yml'].should eq './config/autograders.yml'
      File.should_receive(:file?).and_return true
      File.should_receive(:open).with('config/conf.yml','r').and_return(conf_yml)
      conf = EdXClient.load_configurations('staging')
      conf['queue_uri'].should eq 'https://test.com/staging-queue'
  end

  it 'loads autograder specific configuration' do
    autograder_conf_yml = <<EOF
assign-0-queue:
  name: "test-pull"
  type: WeightedRspecGrader
  due:  20130822205959
  grace_period: 7
  parts:
    assign-0-part-1:
      uri: ../hw/solutions/part1_spec.rb
      type: WeightedRspecGrader
    assign-0-part-2:
      uri: ../hw/solutions/part2_spec.rb
      type: WeightedRspecGrader
    assign-0-part-3:
      uri: ../hw/solutions/part3_spec.rbl
      type: WeightedRspecGrader
EOF
    File.should_receive(:open).with('./config/autograders.yml','r').and_return(autograder_conf_yml)
    autograders = EdXClient.init_autograders('./config/autograders.yml')
    autograders['assign-0-queue'][:name].should eq 'test-pull'
    autograders['assign-0-queue'][:type].should eq 'WeightedRspecGrader'
  end

end