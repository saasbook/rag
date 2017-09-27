describe 'Ruby intro part 1', :sandbox => true do
  describe "#sum" do
    it "should be defined", points: 0 do
      expect { sum([1,3,4]) }.not_to raise_error
    end
  end
end
