# Include hook code here
require 'osx/cocoa'
require File.dirname(__FILE__) + '/lib/p3_indesign'
require File.dirname(__FILE__) + '/lib/p3_indesign_library' 
require File.dirname(__FILE__) + '/lib/p3_indesign_import' 
require File.dirname(__FILE__) + '/lib/p3_indesign_export' 
require File.dirname(__FILE__) + '/lib/p3_indesign_p3s_v1'
require File.dirname(__FILE__) + '/lib/p3_indesign_p3s_v1_lang'
require File.dirname(__FILE__) + '/lib/p3_indesign_coreimg'
require File.dirname(__FILE__) + '/lib/p3_indesign_logger'
require File.dirname(__FILE__) + '/lib/p3_xmlparser'
require File.dirname(__FILE__) + '/lib/p3_hrparser'

require 'rubygems'
require 'appscript' 
#require 'YAML'
require 'activesupport'
require 'base64'
include Appscript

RAILS_ROOT 	= '../../../'
outputDir 	= File.join(ENV['HOME'],'Desktop/test')
testFile	= File.expand_path(File.dirname(__FILE__)) + '/indd-testfiles/brochure_def.indd'
indd 		= P3Indesign_library.new('', '', '', app('Adobe InDesign CS4'))


indd.closeAllDocsNoSave


