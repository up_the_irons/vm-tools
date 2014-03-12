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
    vlan = tap.sub(/^tap\d+-(\d+)(-\d+)?$/, '\1')

    # Remove script; taken care of by hooks now
    if script = interface.at_css('script')
      script.remove
    end
  end

  xml
end

f = File.open(XML_FILE_OLD)
xml = Nokogiri::XML(f)
xml = convert!(xml)
f.close

File.open("#{XML_FILE_NEW}", "w") do |f|
  f.puts(xml.root)
end
