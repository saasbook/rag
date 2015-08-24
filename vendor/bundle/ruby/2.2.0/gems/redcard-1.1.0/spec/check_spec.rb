require 'spec_helper'

describe "RedCard.check" do
  before do
    redcard_save_state
  end

  after do
    redcard_restore_state
  end

  context "when RUBY_VERSION is '2.10.1'" do
    before do
      redcard_version "2.10.1"
    end

    it "returns true for '2.0'" do
      expect(RedCard.check("2.0")).to be_true
    end

    it "returns true for '2.0.0'" do
      expect(RedCard.check("2.0.0")).to be_true
    end

    it "returns true for '2.9.10'" do
      expect(RedCard.check("2.9.10")).to be_true
    end

    it "returns true for '2.10.1'" do
      expect(RedCard.check("2.10.1")).to be_true
    end

    it "returns true for '1.9.100'" do
      expect(RedCard.check("1.9.100")).to be_true
    end

    it "returns true for '1.8.10'" do
      expect(RedCard.check("1.8.10")).to be_true
    end

    it "returns false for '2.10.2'" do
      expect(RedCard.check("2.10.2")).to be_false
    end

    it "returns true for '1.8.10'..'2.10.1'" do
      expect(RedCard.check("1.8.10".."2.10.1")).to be_true
    end

    it "returns true for '1.8.10'..'2.10.2'" do
      expect(RedCard.check("1.8.10".."2.10.2")).to be_true
    end

    it "returns true for '1.8.10'..'2.11'" do
      expect(RedCard.check("1.8.10".."2.11")).to be_true
    end

    it "returns false for '2.10.2'..'2.11.2'" do
      expect(RedCard.check("2.10.2"..."2.11.2")).to be_false
    end

    it "returns false for '1.8.10'...'2.10.1'" do
      expect(RedCard.check("1.8.10"..."2.10.1")).to be_false
    end

    context "when RUBY_ENGINE is 'rbx'" do
      before do
        redcard_engine_version "rbx", "1.0.0"
      end

      it "returns true for '1.9', :rbx" do
        expect(RedCard.check("1.9", :rbx)).to be_true
      end

      it "returns false for '1.9', :topaz" do
        expect(RedCard.check("1.9", :topaz)).to be_false
      end

      context "when Rubinius::VERSION is '2.0.0'" do
        before do
          redcard_engine_version "rbx", "2.0.0"
        end

        it "returns true for '1.9', :rbx => '2.0'" do
          expect(RedCard.check("1.9", :rbx => "2.0")).to be_true
        end

        it "returns true for '1.9', :rbx => '1.2.4'" do
          expect(RedCard.check("1.9", :rbx => "1.2.4")).to be_true
        end

        it "returns false for '1.9', :rbx => '2.1'" do
          expect(RedCard.check("1.9", :rbx => "2.1")).to be_false
        end
      end
    end
  end

  context "when RUBY_ENGINE is 'rbx'" do
    before do
      redcard_engine_version "rbx", "1.0.0"
    end

    it "returns true for :rbx" do
      expect(RedCard.check(:rbx)).to be_true
    end

    it "returns false for :topaz" do
      expect(RedCard.check(:topaz)).to be_false
    end
  end
end
