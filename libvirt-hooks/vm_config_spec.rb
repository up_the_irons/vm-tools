require File.dirname(__FILE__) + '/vm_config'

describe VMConfig do
  context "initialization" do
    it "should create Nokogiri::XML object" do
      xml = "<xml></xml>"
      expect(Nokogiri).to receive(:XML).with(xml)
      VMConfig.new(xml)
    end
  end

  describe "interface_target_device_names()" do
    context "with our sample VM config" do
      before do
        f = File.dirname(__FILE__) + '/sample.xml'
        @xml = File.read(f)
        @vm_config = VMConfig.new(@xml)
      end

      it "should return tap1-950 and tap2-950" do
        expect(@vm_config.interface_target_device_names).to \
          eq(['tap1-950', 'tap2-950'])
      end
    end

    context "with no interaces VM config" do
      before do
        f = File.dirname(__FILE__) + '/sample-no-interfaces.xml'
        @xml = File.read(f)
        @vm_config = VMConfig.new(@xml)
      end

      it "should return empty array" do
        expect(@vm_config.interface_target_device_names).to eq([])
      end
    end

    context "with no target names VM config" do
      before do
        f = File.dirname(__FILE__) + '/sample-no-target-names.xml'
        @xml = File.read(f)
        @vm_config = VMConfig.new(@xml)
      end

      it "should return empty array" do
        expect(@vm_config.interface_target_device_names).to eq([])
      end
    end
  end
end
