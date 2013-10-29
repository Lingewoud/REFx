#!/usr/bin/env ruby

#
#  railsTerminator.rb
#  This script terminates a running PAS3 comserver
#
#  Created by Pim Snel on 06-10-11.
#  Copyright 2011 Lingewoud B.V. All rights reserved.
#

require 'optparse'

# This hash will hold all of the options
# parsed from the command-line by
# OptionParser.
options = {}

optparse = OptionParser.new do|opts|
    
    options[:port] = nil
    opts.on( '-p', '--port PORT', 'port to kill' ) do|port|
        options[:port] = port
    end
    
end

# Parse the command-line. Remember there are two forms
# of the parse method. The 'parse' method simply parses
# ARGV, while the 'parse!' method parses ARGV and removes
# any options found there, as well as any parameters for
# the options. What's left is the list of files to resize.
optparse.parse!

system ("ps x | grep \"script/server webrick --port "+options[:port]+"\" | grep -v grep | kill -9  `awk '{print $1}'`")
exit 0
