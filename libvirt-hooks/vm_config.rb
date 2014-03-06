require 'rubygems'
require 'nokogiri'

class VMConfig
  def initialize(xml)
    @xml = Nokogiri::XML(xml)
  end

  def interface_target_device_names
    names = []

    @xml.css('interface').each do |interface|
      target = interface.at_css 'target'
      if target
        names << target['dev']
      end
    end

    names
  end
end
