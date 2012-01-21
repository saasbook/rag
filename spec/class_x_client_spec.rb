require 'class_x_client'
describe ClassXClient do
  context 'when initialized' do
    it "@autograders should be a mapping from assignment_part_sid's to URIs and cache file paths" do
      assignment_part_sid = 'test-assign-part-1'
      uri = 'http://test.url/'
      File.should_receive(:open).with('autograders.yml', 'r').and_return("#{assignment_part_sid}: #{uri}")
      client = ClassXClient.new("endpoint", "key", 'autograders.yml')
      client.instance_eval{@autograders}.should == {
        assignment_part_sid => { uri: uri, cache: nil},
      }
    end
  end
end
