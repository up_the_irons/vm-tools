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
# - NIC model
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

$VIRSH = '/usr/bin/virsh'
$LIBVIRT_CONN = 'qemu:///system'

def usage
  puts "#{$0} <UUID> <param> <value>"
  puts ""
  puts "param: ram|cpu|cdrom-iso|nic-model"
end

@uuid  = ARGV[0].to_s
@param = ARGV[1].to_s
@value = ARGV[2].to_s
@other = ARGV[3].to_s

if @value.empty? || @param == '--help'
  usage
  exit 1
end

$UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

if !@uuid.match($UUID_REGEX)
  puts "Error: Bad UUID"
  puts ""

  usage
  exit 1
end

def with_libvirt_connection
  conn = Libvirt::open($LIBVIRT_CONN)
  yield conn
  conn.close
end

def with_libvirt_xml(uuid)
  # I'm paranoid, so we'll validate the UUID here as well
  if uuid.match($UUID_REGEX)

    # Not my favorite way of doing things, but conn.xml_desc() will not
    # include the security-info on older libvirt bindings
    contents = %x(#{$VIRSH} dumpxml #{uuid} --security-info --inactive 2>/dev/null)

    xml = Nokogiri::XML(contents)

    if xml
      yield xml
    end
  end
end

def with_libvirt_connection_and_xml(uuid)
  with_libvirt_connection do |conn|
    with_libvirt_xml(uuid) do |xml|
      res = yield conn, xml

      if res
        conn.define_domain_xml(xml.root.to_s)
      end
    end
  end
end

def set_ram(uuid, value)
  with_libvirt_connection_and_xml(uuid) do |conn, xml|
    retval = false

    memory = xml.at_css "memory"
    current_memory = xml.at_css "currentMemory"

    if memory && current_memory
      memory.content = value
      current_memory.content = value
      retval = true
    end

    retval
  end
end

def set_cpu(uuid, value)
  with_libvirt_connection_and_xml(uuid) do |conn, xml|
    retval = false

    cpu = xml.at_css "vcpu"

    if cpu
      cpu.content = value
      retval = true
    end

    retval
  end
end

def set_cdrom_iso(uuid, value)
  with_libvirt_connection_and_xml(uuid) do |conn, xml|
    retval = false

    cdrom = xml.at_css "disk[device=cdrom]"

    if cdrom
      source = cdrom.at_css "source"

      if source
        source['file'] = value
        retval = true
      end
    end

    retval
  end
end

def set_nic_model(uuid, value)
  with_libvirt_connection_and_xml(uuid) do |conn, xml|
    retval = false

    interfaces = xml.css "devices interface"

    interfaces.each do |interface|
      model = interface.at_css "model"

      if model
        model['type'] = value
        retval = true
      end
    end

    retval
  end
end

def set_hd_architecture(uuid, value)
end

case @param
when "ram"
  set_ram(@uuid, @value)
when "cpu"
  set_cpu(@uuid, @value)
when "cdrom-iso"
  set_cdrom_iso(@uuid, @value)
when "nic-model"
  set_nic_model(@uuid, @value)
when "hd-architecture"
  set_hd_architecture(@uuid, @value)
else
  usage
  exit 1
end

