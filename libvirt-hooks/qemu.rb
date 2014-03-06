#!/usr/bin/ruby
#
# :Author: Garry Dolley
# :Date: 03-05-2014
#
# Create bridge and tap(s) needed for a VM

$:.unshift File.dirname(__FILE__)

require 'vm_config'

@guest_name = ARGV[0].to_s
@phase      = ARGV[1].to_s
@command    = ARGV[2].to_s

@xml = STDIN.read

case @command
when 'begin'
  case @phase
  when 'prepare'
    config = VMConfig.new(@xml)

    config.interface_target_device_names.each do |target|
      %x(/path/to/prepare.sh #{target})
    end
  end
end
