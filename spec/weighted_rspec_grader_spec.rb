require 'spec_helper'

describe WeightedRspecGrader do
  def fake_rspec_output(str)
    ::RspecRunner.any_instance.stub(:run_rspec).and_return(str)
  end
  it 'should give error when initializing with no specs' do
    lambda { WeightedRspecGrader.new('foo', {}) }.should raise_error RspecGrader::NoSpecsGivenError
  end
  it 'should give error when initializing with non existent spec' do
    lambda { WeightedRspecGrader.new('foo', {:spec => 'spec/fixtures/non_existent.spec.rb'}) }.should raise_error RspecGrader::NoSuchSpecError
  end
  describe 'running valid specfile should be able to correctly parse rspec text output' do
    before :each do
      @g = WeightedRspecGrader.new('foo', :spec => 'spec/fixtures/correct_example.spec.rb')
    end
    it 'should give 3 points, when 3 points specified' do
      fake_rspec_output 'correctly converts currency from euro to dollars (plural) [3 points]'
      @g.grade!
      @g.normalized_score.should == 100
    end
    it 'should give 3 points, when 3 points specified, even with exclamation' do
      fake_rspec_output 'correctly converts currency from euro to dollars! (plural) [3 points]'
      @g.grade!
      @g.normalized_score.should == 100
    end
    it 'should round up to 67% for 2 out of 3' do
      fake_rspec_output "correctly converts currency from yen to dollars (plural) [1 points] (FAILED) \r\n correctly
converts currency from yen to dollars (plural) [2 points]"
      @g.grade!
      @g.normalized_score.should == 67
    end
    it 'should give 0% when failing' do
      fake_rspec_output "correctly converts currency from yen to dollars (plural) [1 points] (FAILED) "
      @g.grade!
      @g.normalized_score.should == 0
    end
    it 'should give 0 (not exception) for all failures' do
      fake_rspec_output '3 examples, 3 failures'
      @g.grade!
      @g.normalized_score.should == 0
    end
  end
end
