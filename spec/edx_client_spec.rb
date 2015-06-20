require 'spec_helper'

describe EdXClient do
  describe 'new' do
    it 'default initialization results' do
      pending "feature is deprecated"
      client =  EdXClient.new
      expect(client.instance_variable_get { "@conf_name" }).to eq(nil)
      expect(client.instance_eval { "@conf_path" }).to eq('config/conf.yml')
    end
  end

  describe "#run" do
    describe "#generate_late_response" do
      it 'should generate a late response' do
        pending "feature is deprecated"
        client = EdXClient.new
        client.send(:generate_late_response, 20131014060000, 20131014050000, 0, 1).should eq [0.5, "It's less than 1 day(s) late: score scaled by: .5\n"]
      end
    end
  end
end
