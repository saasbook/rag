require 'spec_helper'

describe "RedCard.verify" do
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

    it "returns nil for '2.0'" do
      expect(RedCard.verify("2.0")).to be_nil
    end

    it "returns nil for '2.0.0'" do
      expect(RedCard.verify("2.0.0")).to be_nil
    end

    it "returns nil for '2.9.10'" do
      expect(RedCard.verify("2.9.10")).to be_nil
    end

    it "returns nil for '2.10.1'" do
      expect(RedCard.verify("2.10.1")).to be_nil
    end

    it "returns nil for '1.9.100'" do
      expect(RedCard.verify("1.9.100")).to be_nil
    end

    it "returns nil for '1.8.10'" do
      expect(RedCard.verify("1.8.10")).to be_nil
    end

    it "raises an InvalidRubyVersionError for '2.10.2'" do
      expect { RedCard.verify("2.10.2") }.to raise_error(RedCard::InvalidRubyVersionError)
    end

    it "returns nil for '1.8.10'..'2.10.1'" do
      expect(RedCard.verify("1.8.10".."2.10.1")).to be_nil
    end

    it "returns nil for '1.8.10'..'2.10.2'" do
      expect(RedCard.verify("1.8.10".."2.10.2")).to be_nil
    end

    it "returns nil for '1.8.10'..'2.11'" do
      expect(RedCard.verify("1.8.10".."2.11")).to be_nil
    end

    it "raises an InvalidRubyVersionError for '2.10.2'..'2.11.2'" do
      expect { RedCard.verify("2.10.2"..."2.11.2") }.to raise_error(RedCard::InvalidRubyVersionError)
    end

    it "raises an InvalidRubyVersionError for '1.8.10'...'2.10.1'" do
      expect { RedCard.verify("1.8.10"..."2.10.1") }.to raise_error(RedCard::InvalidRubyVersionError)
    end

    context "when RUBY_ENGINE is 'rbx'" do
      before do
        redcard_engine_version "rbx", "1.0.0"
      end

      it "returns nil for '1.9', :rbx" do
        expect(RedCard.verify("1.9", :rbx)).to be_nil
      end

      it "raises an InvalidRubyEngineError for '1.9', :topaz" do
        expect { RedCard.verify("1.9", :topaz) }.to raise_error(RedCard::InvalidRubyEngineError)
      end

      context "when Rubinius::VERSION is '2.0.0'" do
        before do
          redcard_engine_version "rbx", "2.0.0"
        end

        it "returns nil for '1.9', :rbx => '2.0'" do
          expect(RedCard.verify("1.9", :rbx => "2.0")).to be_nil
        end

        it "returns nil for '1.9', :rbx => '1.2.4'" do
          expect(RedCard.verify("1.9", :rbx => "1.2.4")).to be_nil
        end

        it "raises an InvalidRubyError for '1.9', :rbx => '2.1'" do
          expect { RedCard.verify("1.9", :rbx => "2.1") }.to raise_error(RedCard::InvalidRubyError)
        end
      end
    end
  end

  context "when RUBY_ENGINE is 'rbx'" do
    before do
      redcard_engine_version "rbx", "1.0.0"
    end

    it "returns nil for :rbx" do
      expect(RedCard.verify(:rbx)).to be_nil
    end

    it "raises an InvalidRubyEngineError for :topaz" do
      expect { RedCard.verify(:topaz) }.to raise_error(RedCard::InvalidRubyEngineError)
    end
  end
end

