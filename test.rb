require "rspec/autorun"

describe "an object" do
  before :all do
    @shared_thing = Object.new
  end

  before :each do
    @something = Object.new
  end

  it "should be an Object" do
    @something.should be_an(Object)
  end

  describe "compared to another object" do
    before :each do
      @other = Object.new
    end

    it "should not be equal" do
      @something.should_not == @other
    end
  end

  after do
    @something = nil
  end
end