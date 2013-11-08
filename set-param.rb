#!/usr/bin/env ruby
#
# Author: Garry Dolley
# Date: 11-08-2013
#
# Set a select list of VM parameters within a libvirt domain (VM)
#
# Available parameters that can be set include:
#
# - RAM
# - CPU
# - CD-ROM ISO
#
# Background:
#
# libvirt is not very good at letting one change VM parameters on the command
# line (ironically), especially in older versions.  One can, however, grab the
# XML definition of a VM, manipulate it, and then define the VM again using
# the modified XML.  The new parameters seem to stick.
#
# For example, if one tries to change the amount of RAM that is allocated to
# a VM, using 'setmem', well, good luck.  I could not get this to work.
# Changing the CD-ROM ISO with 'attach-disk' is annoying (doesn't always work
# depending on VM state).  Try setting the number of CPU cores (vcpu), you
# can't.

require 'rubygems'
require 'nokogiri'
require 'libvirt'

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
