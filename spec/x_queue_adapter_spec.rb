require 'spec_helper'
include Adapter
describe Xqueue do
  context 'initialization from adapter factory with config file' do
    before(:each) do 
      @x_queue = create_adapter('./spec/fixtures/x_queue_config.yml')
    end
    it 'should not crash' do 
      expect(@x_queue).to be
    end
  end
end