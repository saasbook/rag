require 'spec_helper'

describe "Loading autograder files" do

  autograder_info = {
    "assign-0-queue" => {
      "name" => "test-pull",
      "type" => "WeightedRspecGrader",
      :due => 20130822205959,
      :grace_period => 7,
      :parts => {
        "assign-0-part-1" => {
          "uri" => "../hw/solutions/part1_spec.rb",
          "type" => "WeightedRspecGrader"
        },
        "assign-0-part-2" => {
          "uri" => "http://remote-spec-location.org",
          "type" => "WeightedRspecGrader"
        }

      }
    }
  }



  before(:each) do
      EdXClient.any_instance.stub(:initialize){}
      @controller = double('fake controller').as_null_object
      EdXController.stub(:new).and_return(@controller)
  end

  let(:client) do
    e_client = EdXClient.new
    e_client.instance_eval { @autograders = autograder_info}
    e_client
  end

  it "Loading the spec should return the [spec_uri,grader_type] uri is not remote" do
    client.send(:load_spec, "assign-0-queue", "assign-0-part-1").should eq ["../hw/solutions/part1_spec.rb", "WeightedRspecGrader" ]
  end

  it "Should raise an error if the assignment_part_sid is not found" do
    lambda{ client.send(:load_spec, "assign-fake-queue", "assign-0-part-1") }.should raise_error
  end

  it "Should raise an error if the part name is not found" do
    lambda{ client.send(:load_spec, "assign-0-queue", "assign-fake-part") }.should raise_error
  end

end
