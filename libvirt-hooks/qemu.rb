#!/usr/bin/ruby
#
# :Author: Garry Dolley
# :Date: 03-05-2014
#
# Create bridge and tap(s) needed for a VM

require 'rubygems'
require 'nokogiri'

@guest_name = ARGV[0].to_s
@phase      = ARGV[1].to_s
@command    = ARGV[2].to_s

$stderr.puts 'foo'
