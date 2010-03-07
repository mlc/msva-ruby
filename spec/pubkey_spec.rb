require File.dirname(__FILE__) + '/spec_helper'

MLC_RSA_KEY = "AAAAB3NzaC1yc2EAAAADAQABAAABAQC54fy+yjruEdKXJr6C9hjTKCQ5HMRTjTB3pbjY6MhZB4W4RgKhzd/R2MFcFylxiSvIw6KrJ8XNc5derxpg2M0UEgoMQCvCjpv++5R6oiUpXh2UGVaSoXe9nyDhLNC7VLlfNU7rYqgkNQyldqBtzqMDAwnXcH/AjRnCR2Mxfa+GfBiR+hZ+qkG8GgfzwArAfBKBRhVfBICb6R8afFJ0tuzgP3TFShR569Wu74mxttjKm89NI/W6kHq+p66WDu9FrXFsfm/QI4Po29BkRQ7B9Rnl+xclqO/OAU87QbqIV2FxJUF/opHRos8cFD+cH2SovXyBXL31TeNioAhXNKJnQIoN"
MLC_DSS_KEY = "AAAAB3NzaC1kc3MAAACBANjuJ3Mvy7+6FT9R38l1PQgy2lPhNZu+jJUOfY6SQ0qLGAYe5CIs4gkGKYcGoKd58y7BP/vgEJKrUS+lwqRJODfZLkUjLFrJ+7lDtNz3nBPmMyR/Q3AjJp5Y2Nh53idC6Sl5BOVcRCGVhv9/PN23EhFff0el2Wm27u5JQQDJo2gPAAAAFQCCNXjocptLFa0nI9t3d2PqAftWHwAAAIAXIjAL/IhWWtTZdhSKMK7izc6s+74FaFHt9RGh3KwfeGeyTmz2ppEDXznEFqoLrlEjCTt/Un87fMv2mJwO5lYuipUpQN9yTJC5Y1bp2veNomGC9936EOFaD946uxK6GPIYUWYviYE5ugJD1IJKqFhniCn9HpOLGdtfaUTBHDA68QAAAIAe3VDbL37SnTJmzsfGi58/eJsdACcwqk9HQ7TqLLUY7exCr0dcQWuBSfIDJTNxdNYpyB7GAZEap6rxBmqOIUAGa9kmUVwUi+PT1bTYqMnZ+wRn6IhCqXKSgkN0g1peQEfslPJcsGJArS8lUfVMigBnWn4mnhjebPVceF8o4CRt0Q=="

describe OpenSshPubKey do
  describe "RSA" do
    describe "initialization" do
      it "should complain when being fed an empty string" do
        lambda{ OpenSshPubKey::RSA.new("") }.should raise_error
      end

      it "should reject a DSS key" do
        lambda{ OpenSshPubKey::RSA.new(MLC_DSS_KEY) }.should raise_error
      end

      it "should happily accept a valid key" do
        lambda{ OpenSshPubKey::RSA.new(MLC_RSA_KEY) }.should_not raise_error
      end

      it "should create a nil key when not fed an argument" do
        nilkey = OpenSshPubKey::RSA.new
        nilkey.should_not be_nil
        nilkey.n.should be_nil
        nilkey.e.should be_nil
      end

      it "should parse the key properly" do
        pkey = OpenSshPubKey::RSA.new(MLC_RSA_KEY)
        pkey.e.should == 65537
        pkey.e.should be_a_kind_of OpenSSL::BN
        pkey.n.should_not be_nil
        pkey.n.should be_a_kind_of OpenSSL::BN
      end
    end

    describe ".to_s" do
      it "should reconstruct the key and spit it back out" do
        pkey = OpenSshPubKey::RSA.new(MLC_RSA_KEY)
        pkey.to_s.should == MLC_RSA_KEY
      end
    end
  end

  describe "DSS" do
    describe "initialization" do
      it "should complain when being fed an empty string" do
        lambda{ OpenSshPubKey::DSS.new("") }.should raise_error
      end

      it "should reject an RSA key" do
        lambda{ OpenSshPubKey::DSS.new(MLC_RSA_KEY) }.should raise_error
      end

      it "should happily accept a valid key" do
        lambda{ OpenSshPubKey::DSS.new(MLC_DSS_KEY) }.should_not raise_error
      end

      it "should create a nil key when not fed an argument" do
        nilkey = OpenSshPubKey::DSS.new
        nilkey.should_not be_nil
        nilkey.p.should be_nil
        nilkey.q.should be_nil
        nilkey.g.should be_nil
        nilkey.pub_key.should be_nil
      end

      it "should parse the key properly" # how do we know?
    end

    describe ".to_s" do
      it "should reconstruct the key and spit it back out" do
        pkey = OpenSshPubKey::DSS.new(MLC_DSS_KEY)
        pkey.to_s.should == MLC_DSS_KEY
      end
    end
  end

  describe ".parse" do
    it "should accept and parse an RSA key" do
      pkey = OpenSshPubKey.parse("ssh-rsa " + MLC_RSA_KEY)
      pkey.should be_a_kind_of OpenSshPubKey::RSA
      pkey.to_s.should == MLC_RSA_KEY
    end

    it "should accept and parse a DSS key" do
      pkey = OpenSshPubKey.parse("ssh-dss " + MLC_DSS_KEY)
      pkey.should be_a_kind_of OpenSshPubKey::DSS
      pkey.to_s.should == MLC_DSS_KEY
    end

    it "should blow up on wrongly labeled keys" do
      lambda { OpenSshPubKey.parse("ssh-dss " + MLC_RSA_KEY) }.should raise_error
      lambda { OpenSshPubKey.parse("ssh-rsa " + MLC_DSS_KEY) }.should raise_error
    end
  end
end
