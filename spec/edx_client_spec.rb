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
  late_period: 2
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
    autograders['assign-0-queue'][:late_period].should eq 2
  end



  describe "#run" do
    before :each do
      EdXController.stub(:new).and_return(controller)
      autograder = {'test-assignment' => { :uri => 'http://example.com', :type => 'RspecGrader' } }
      conf = {}
      conf['queue_uri'] = 'https://test.com/live-queue'
      conf['autograders_yml'] = './config/autograders.yml'
      conf['user_auth'] = {"user_name"=>"user-name", "user_pass"=>"user-password"}
      conf['django_auth'] = {"username"=>"django-user", "password"=>"django-password"}
      conf['halt'] = false
      conf['sleep_duration'] = 30
      EdXClient.stub(:load_configurations).and_return(conf)
      EdXClient.stub(:init_autograders).and_return(autograder)
    end
    let(:controller) { double('fake controller').as_null_object }
    let(:submission) { double('fake_submission').as_null_object }


    context "with one autograder" do

      it 'should exit if the submission queue is empty (under test)' do
        controller.should_receive(:get_queue_length).and_return(0)
        client = EdXClient.new()
        eval("class EdXClient; def continue_running_test(x); x > 0; end; end;")
        client.run
      end
      
      it 'should reload the autograders\' config after each sleep' do
        wrong_autograder = {'test-assignment2' => { :uri => 'foo.com', :type => 'RspecGrader' } }
        autograder = {'test-assignment' => { :uri => 'http://example.com', :type => 'RspecGrader' } }
        EdXClient.stub(:init_autograders).and_return(wrong_autograder,autograder)
        EdXClient.any_instance.stub(:continue_running_test).and_return(true,true,false)
        EdXClient.any_instance.stub(:sleep)
        controller.should_receive(:get_queue_length).and_return(0,0,1,1)
        controller.should_receive(:authenticate)
        controller.stub(:get_submission).and_return(submission)
        client = EdXClient.new()
        client.should_receive(:load_spec)
        client.should_receive(:load_due_date)
        client.should_receive(:load_grace_period)
        client.stub(:generate_late_response).and_return(1,"")
        client.should_receive(:write_student_submission)
        client.stub(:run_autograder_subprocess).and_return(100,"woot!")
        client.should_receive(:format_for_html).and_return("woot!")
        controller.should_receive(:send_grade_response)
        expect {client.run}.to change {client.autograders}.from(wrong_autograder).to(autograder)

      end

      describe "#late period" do
         before :each do
          autograder = {
            'test-assignment' => {
              :uri => 'http://example.com',
              :type => 'RspecGrader',
              :due => 14921012060000,
              :grace_period => 31,
              :late_period => 2,
              :parts => {
                'test-part-1' => {
                  'uri' => "../hw/solutions/test_part1_spec.rb",
                  'type' => 'RspecGrader',
                  'due' => 17760704120000,
                  'grace_period' => 1,
                  'late_period' => 3,
                },
                'test-part-2' => {
                  'uri' => "../hw/solutions/test_part2_spec.rb",
                  'type' => 'RspecGrader',
                  'due' => 18630101130000,
                  'grace_period' => 8
                }
              }
            }
          }
        EdXClient.stub(:init_autograders).and_return(autograder)
        end

        it 'should load default late period' do
          client = EdXClient.new()
          client.send(:load_late_period, 'test-assignment').should eq 2
        end
      end



      describe "#due date and grace period" do
        before :each do
          autograder = {
            'test-assignment' => {
              :uri => 'http://example.com',
              :type => 'RspecGrader',
              :due => 14921012060000,
              :grace_period => 31,
              :late_period => 2,
              :parts => {
                'test-part-1' => {
                  'uri' => "../hw/solutions/test_part1_spec.rb",
                  'type' => 'RspecGrader',
                  'due' => 17760704120000,
                  'grace_period' => 1,
                  'late_period' => 3,
                },
                'test-part-2' => {
                  'uri' => "../hw/solutions/test_part2_spec.rb",
                  'type' => 'RspecGrader',
                  'due' => 18630101130000,
                  'grace_period' => 8
                }
              }
            }
          }
          EdXClient.stub(:init_autograders).and_return(autograder)
        end

        it 'should use part specific due date and grace period if available' do
          client = EdXClient.new()
          client.send(:load_due_date, 'test-assignment', 'test-part-1').should eq 17760704120000
          client.send(:load_due_date, 'test-assignment', 'test-part-2').should eq 18630101130000
          client.send(:load_grace_period, 'test-assignment', 'test-part-1').should eq 1
          client.send(:load_grace_period, 'test-assignment', 'test-part-2').should eq 8
        end

        it 'should fall back to queue specific due date and grace period if part specific not available' do
          client = EdXClient.new()
          client.autograders['test-assignment'][:parts]['test-part-1'].delete('due')
          client.autograders['test-assignment'][:parts]['test-part-1'].delete('grace_period')
          client.autograders['test-assignment'][:parts]['test-part-2'].delete('due')
          client.autograders['test-assignment'][:parts]['test-part-2'].delete('grace_period')
          client.send(:load_due_date, 'test-assignment', 'test-part-1').should eq 14921012060000
          client.send(:load_due_date, 'test-assignment', 'test-part-2').should eq 14921012060000
          client.send(:load_due_date, 'test-assignment').should eq 14921012060000
          client.send(:load_grace_period, 'test-assignment', 'test-part-1').should eq 31
          client.send(:load_grace_period, 'test-assignment', 'test-part-2').should eq 31
          client.send(:load_grace_period, 'test-assignment').should eq 31
        end

        it 'should fall back to default values if queue and part specific are not available' do
          client = EdXClient.new()
          client.autograders['test-assignment'][:parts]['test-part-1'].delete('due')
          client.autograders['test-assignment'][:parts]['test-part-1'].delete('grace_period')
          client.autograders['test-assignment'][:parts]['test-part-2'].delete('due')
          client.autograders['test-assignment'][:parts]['test-part-2'].delete('grace_period')
          client.autograders['test-assignment'].delete(:due)
          client.autograders['test-assignment'].delete(:grace_period)
          client.send(:load_due_date, 'test-assignment', 'test-part-1').should eq 20250910031500
          client.send(:load_due_date, 'test-assignment', 'test-part-2').should eq 20250910031500
          client.send(:load_due_date, 'test-assignment').should eq 20250910031500
          client.send(:load_grace_period, 'test-assignment', 'test-part-1').should eq 8
          client.send(:load_grace_period, 'test-assignment', 'test-part-2').should eq 8
          client.send(:load_grace_period, 'test-assignment').should eq 8
        end
      end
      it 'should reload the autograders\' config after each sleep' do
        wrong_autograder = {'test-assignment2' => { :uri => 'foo.com', :type => 'RspecGrader' } }
        autograder = {'test-assignment' => { :uri => 'http://example.com', :type => 'RspecGrader' } }
        EdXClient.stub(:init_autograders).and_return(wrong_autograder,autograder)
        EdXClient.any_instance.stub(:continue_running_test).and_return(true,true,false)
        EdXClient.any_instance.stub(:sleep)
        controller.should_receive(:get_queue_length).and_return(0,0,1,1)
        controller.should_receive(:authenticate)
        controller.stub(:get_submission).and_return(submission)
        client = EdXClient.new()
        client.should_receive(:load_spec)
        client.should_receive(:load_due_date)
        client.should_receive(:load_grace_period)
        client.stub(:generate_late_response).and_return(1,"")
        client.should_receive(:write_student_submission)
        client.stub(:run_autograder_subprocess).and_return(100,"woot!")
        client.should_receive(:format_for_html).and_return("woot!")
        controller.should_receive(:send_grade_response)
        expect {client.run}.to change {client.autograders}.from(wrong_autograder).to(autograder)

      end


      it 'should authenticate with EdX, grab submission and grade it' do
        controller.should_receive(:get_queue_length).and_return(1,1,0)
        controller.should_receive(:authenticate)
        controller.stub(:get_submission).and_return(submission)
        client = EdXClient.new()
        client.should_receive(:load_spec)
        client.should_receive(:load_due_date)
        client.should_receive(:load_grace_period)
        client.stub(:generate_late_response).and_return(1,"")
        client.should_receive(:write_student_submission)
        client.stub(:run_autograder_subprocess).and_return(100,"woot!")
        client.should_receive(:format_for_html).and_return("woot!")
        controller.should_receive(:send_grade_response)
        eval("class EdXClient; def continue_running_test(x); x > 0; end; end;")
        client.run
      end

    end
  end

end
