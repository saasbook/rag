describe 'Ruby intro part 1', :sandbox => true do
  describe "#sum" do
    it "should be defined", points: 0 do
      expect { sum([1,3,4]) }.not_to raise_error
    end

    it "returns correct sum [20 points]", focus: false, points: 20 do
      expect(sum([1,2,3,4,5])).to be_a_kind_of Fixnum
      expect(sum([1,2,3,4,5])).to eq 15
      expect(sum([1,2,3,4,-5])).to eq 5
      expect(sum([1,2,3,4,-5,5,-100])).to eq -90
    end

    it "works on the empty array [10 points]", points:10 do
      expect { sum([]) }.not_to raise_error
      expect(sum([])).to be_zero
    end

  end

  describe "#max_2_sum" do
    it "should be defined", points:0 do
      expect { max_2_sum([1,2,3]) }.not_to raise_error
    end
    it "returns the correct sum [7 points]", points:7 do
      expect(max_2_sum([1,2,3,4,5])).to be_a_kind_of Fixnum
      expect(max_2_sum([1,-2,-3,-4,-5])).to eq -1
    end
    it 'works even if 2 largest values are the same [3 points]', points:3 do
      expect( max_2_sum([1,2,3,3])).to eq 6
    end
    it "returns zero if array is empty [10 points]", points:10 do
      expect(max_2_sum([])).to be_zero
    end
    it "returns value of the element if just one element [10 points]", points:10 do
      expect(max_2_sum([3])).to eq 3
    end
  end

  describe "#sum_to_n" do
    it "should be defined", points:0 do
      expect { sum_to_n?([1,2,3],4) }.not_to raise_error
    end
    it "returns the correct sum [30 points]", points:30 do
      expect(sum_to_n?([1,2,3,4,5], 5)).to be_true
      expect(sum_to_n?([3,0,5], 5)).to be_true
      expect(sum_to_n?([-1,-2,3,4,5,-8], 12)).to be_false
    end
    it "returns false for the empty array with nonzero argument [5 points]", points:5 do
      expect(sum_to_n?([], 1)).to be_false
    end
    it "returns true for the empty array with zero argument [5 points]", points:5 do
      expect(sum_to_n?([], 0)).to be_true
    end
  end
end
