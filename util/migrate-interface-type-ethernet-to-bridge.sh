#!/bin/sh
#
# :Author: Garry Dolley
# :Date: 03-11-2014
#
# I can't seem to get Nokogiri::XML to format our resulting XML from
# migrate-interface-type-ethernet-to-bridge.rb into a nice, consistent
# format.  Newlines are not added after inserted nodes, and removed
# nodes become a line of nothing but trailing white space.
#
# This script runs the output through xmllint (part of libxml2-utils)
# package (Debian/Ubuntu) and makes it pretty.  Also, I translate all
# double quotes back to single quotes because that is how libvirt saves
# its XML files, and I need a diff between the old and new format to
# be meaningful (as opposed to almost every line changed).  Lastly, I
# remove the XML header that xmllint inserts.

usage() {
  echo "$0 <file-old> <file-new>"
  exit 1
}

XML_FILE_OLD=$1
XML_FILE_NEW=$2

if [ -z "$XML_FILE_NEW" ]; then
  usage
fi

./migrate-interface-type-ethernet-to-bridge.rb $XML_FILE_OLD - | \
  xmllint --format - > $XML_FILE_NEW

TMP=$(mktemp)

if [ -n "$TMP" ]; then
  cat $XML_FILE_NEW | tr \" \' | tail -n +2 > $TMP
  mv $TMP $XML_FILE_NEW
fi
