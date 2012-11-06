# Include hook code here
require File.dirname(__FILE__) + '/lib/p3ga_indesign'
require File.dirname(__FILE__) + '/lib/p3ga_debug'
require File.dirname(__FILE__) + '/lib/p3ga_xmlparser'
require File.dirname(__FILE__) + '/lib/p3ga_hrparser'

require 'rubygems'
require 'appscript' 
require 'YAML'

outputDir= File.join(ENV['HOME'],'Desktop')
#def initialize(working_dir_root, repository_root, outputPath, filePath, test = false)
#indd = P3gaIndesign.new(outputDir, nil , File.expand_path(File.dirname(__FILE__)) + '/indd-testfiles/sourcedoc.indd', true)
indd = P3gaIndesign.new('','',outputDir, File.expand_path(File.dirname(__FILE__)) + '/indd-testfiles/sourcedoc.indd', true)

indd.dryRun(true)
puts indd.getXML
#puts indd.getHumanReadable
#puts indd.getPreview
