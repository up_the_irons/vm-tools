#!/usr/bin/env ruby
#
# Author: Garry Dolley
# Date: 11-08-2013
#
# Set a select list of VM parameters
#
# Available parameters that can be set include:
#
# - RAM
# - CPU
# - CD-ROM ISO

def usage
  puts "#{$0} <UUID> <ram|cpu|cdrom-iso> <value>"
end

@uuid  = ARGV[0].to_s
@param = ARGV[1].to_s
@value = ARGV[2].to_s
@other = ARGV[3].to_s

if @value.empty? || @param == '--help'
  usage
  exit 1
end
