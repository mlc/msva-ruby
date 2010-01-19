require File.dirname(__FILE__) + '/spec_helper'

MLC_KEY = "AAAAB3NzaC1yc2EAAAADAQABAAABAQC54fy+yjruEdKXJr6C9hjTKCQ5HMRTjTB3pbjY6MhZB4W4RgKhzd/R2MFcFylxiSvIw6KrJ8XNc5derxpg2M0UEgoMQCvCjpv++5R6oiUpXh2UGVaSoXe9nyDhLNC7VLlfNU7rYqgkNQyldqBtzqMDAwnXcH/AjRnCR2Mxfa+GfBiR+hZ+qkG8GgfzwArAfBKBRhVfBICb6R8afFJ0tuzgP3TFShR569Wu74mxttjKm89NI/W6kHq+p66WDu9FrXFsfm/QI4Po29BkRQ7B9Rnl+xclqO/OAU87QbqIV2FxJUF/opHRos8cFD+cH2SovXyBXL31TeNioAhXNKJnQIoN"

describe OpenSshPubKey do
  describe "initialization" do
    it "should complain when being fed an empty string" do
      lambda{ OpenSshPubKey.new("") }.should raise_error
    end

    it "should happily accept a valid key" do
      lambda{ OpenSshPubKey.new(MLC_KEY) }.should_not raise_error
    end

    it "should create a nil key when not fed an argument" do
      nilkey = OpenSshPubKey.new
      nilkey.should_not be_nil
      nilkey.n.should be_nil
      nilkey.e.should be_nil
    end

    it "should parse the key properly" do
      pkey = OpenSshPubKey.new(MLC_KEY)
      pkey.e.should == 65537
      pkey.e.should be_a_kind_of OpenSSL::BN
      pkey.n.should_not be_nil
      pkey.n.should be_a_kind_of OpenSSL::BN
    end
  end

  describe ".to_s" do
    it "should reconstruct the key and spit it back out" do
      pkey = OpenSshPubKey.new(MLC_KEY)
      pkey.to_s.should == MLC_KEY
    end
  end
end
