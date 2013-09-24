require 'spec_helper'

describe 'Due Dates' do
	let(:client){ EdXClient.new }


	describe "#load_due_date" do
    before(:each) do
      EdXClient.any_instance.stub(:initialize)
      client.instance_eval{ @autograders = {"assignment_part_sid_1" => {} }}
    end

    it "Should raise an error if the assignment_part_sid is not in the autograders hash" do
      lambda { client.instance_eval{load_due_date("fake_part_sid")} }.should raise_error
    end

    it "Should not raise an error if the entry for assignment_part_sid does not have :due as a key" do
      puts "the ag hash is: " + client.instance_eval{@autograders}.to_s
      lambda { client.instance_eval{load_due_date("assignment_part_sid_1")} }.should_not raise_error
    end

    it "Should return the date 20250910031500 if the assignment_part_sid does not have a due date entered" do
      client.instance_eval{load_due_date("assignment_part_sid_1")}.should eq 20250910031500
    end

    it "Should return the entry stored under @autograders[assignment_part_sid][:due] if it exists" do
      client.instance_eval{ @autograders["assignment_part_sid_1"][:due] = 20050910031500 }
      client.instance_eval{load_due_date("assignment_part_sid_1")}.should eq 20050910031500
    end

	end

  describe "#load_grace_period" do
    before(:each) do

      EdXClient.any_instance.stub(:initialize)
      client.instance_eval{ @autograders = {
        "assignment_part_with_grace_period" => {:grace_period => 123},
        "assignment_part_without_grace_period" => {}
        }
      }

    end

    it "Should raise an error if the assignment_part_sid is not in the autograders hash" do
      lambda { client.instance_eval{load_grace_period("fake_part_sid")} }.should raise_error
    end

    it "Should not raise an error if the entry for assignment_part_sid does not have :grace_period as a key" do
      puts "the ag hash is: " + client.instance_eval{@autograders}.to_s
      lambda { client.instance_eval{load_grace_period("assignment_part_without_grace_period")} }.should_not raise_error
    end

    it "Should return a default value of 8 if the assignment_part_sid does not have a grace_period entered" do
      client.instance_eval{load_grace_period("assignment_part_without_grace_period")}.should eq 8
    end

    it "Should return the entry stored under @autograders[assignment_part_sid][:due] if it exists" do
      client.instance_eval{load_grace_period("assignment_part_with_grace_period")}.should eq 123
    end

  end

describe "generate_late_response" do
  # generate_late_response(received_date, due_date,grace_period)
    before(:each) do
      EdXClient.any_instance.stub(:initialize)
    end

    it "Should return an array" do
      client.send(:generate_late_response, 20250910031500, 20250910031500, 8).should  be_kind_of(Array)
    end

    context "On Time" do
      subject do
        client.send(:generate_late_response, 20240910031500, 20250910031500, 8)
      end

      specify{subject[0].should eq 1.0}
      specify{subject[1].should match(/On Time/)}
    end

    context "Under one grace_period late" do
      subject do
        client.send(:generate_late_response, 20250917031500, 20250910031500, 8)
      end

      specify{subject[0].should eq 0.75}
      specify{subject[1].should match(/Late assignment: score scaled by .75/)}

    end

    context "Between one and two grace periods late" do
      subject do
        client.send(:generate_late_response, 20250919031500, 20250910031500, 8)
      end

      specify{subject[0].should eq 0.5}
      specify{subject[1].should match(/Between one and two/)}

    end

    context "More than two grace periods late" do
      subject do
        client.send(:generate_late_response, 20290919031500, 20250910031500, 8)
      end

      specify{subject[0].should eq 0.0}
      specify{subject[1].should match(/no points awarded/)}

    end

  end

end


