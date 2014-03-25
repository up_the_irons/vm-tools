#!/usr/bin/ruby
#
# :Author: Garry Dolley
# :Date: 03-11-2014

require 'rubygems'
require 'nokogiri'

XML_FILE_OLD=ARGV[0].to_s
XML_FILE_NEW=ARGV[1].to_s

def usage
  puts "./migrate-interface-type-ethernet-to-bridge.rb <file-old> <file-new>"
  exit 1
end

usage if XML_FILE_NEW.empty?

def convert!(xml)
  xml.css('interface').each do |interface|
    # Change interface type
    interface['type'] = 'bridge'

    # Add bridge source
    target = interface.at_css 'target'
    tap = target['dev']
    vlan = tap.sub(/^tap\d+-(.+?)(-\d+)?$/, '\1')
    source = Nokogiri::XML::Node.new "source", xml
    source['bridge'] = "br#{vlan}"
    interface << source

    # Remove script; taken care of by hooks now
    if script = interface.at_css('script')
      script.remove
    end
  end

  # Not really in the theme of this script, but we need it anyway to convert
  # some old VMs
  if emulator = xml.at_css('emulator')
    emulator.content = '/usr/bin/kvm'
  end

  xml
end

f = File.open(XML_FILE_OLD)
xml = Nokogiri::XML(f)
f.close

xml = convert!(xml)

if XML_FILE_NEW == '-'
  puts xml.root
else
  File.open("#{XML_FILE_NEW}", "w") do |f|
    f.puts(xml.root)
  end
end
