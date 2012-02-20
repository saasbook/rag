require 'coursera_client'

describe CourseraClient do
  context 'when initialized' do
    it "@autograders should be a mapping from assignment_part_sid's to URIs and grader types" do
      autograders_yml = <<EOF
test-assign-1-part-1: 
  uri: http://test.url/
  type: WeightedRspecGrader
EOF
      File.should_receive(:open).with('autograders.yml', 'r').and_return(autograders_yml)

      client = CourseraClient.new("endpoint", "key", 'autograders.yml')
      client.instance_eval{@autograders}.should == {
        'test-assign-1-part-1' => { uri: 'http://test.url/', type: 'WeightedRspecGrader'},
      }
    end
  end
end
