require 'grader'

describe 'Command Line Interface' do
  it 'should exist' do
    expect(Grader).not_to be_nil
  end
  it "should define a cli method" do
    lambda { Grader.cli }.should_not raise_error(::NoMethodError)
  end
  it 'should display help when args are not appropriate' do
    expect(Grader.cli(["some"])).to eq Grader.help
  end
  it 'should have a method to grade based on incoming arguments' do
    expect(Grader.cli(["some","args"])).not_to eq Grader.help
  end
  it 'should produce appropriate response to sensible input' do
    result = Grader.cli(["correct_example.rb","correct_example.spec.rb"])
    expect(result).not_to eq Grader.help
  end
  xit 'should have a to_s method to output the results but allow other tests to check things without parsing' do

  end
end