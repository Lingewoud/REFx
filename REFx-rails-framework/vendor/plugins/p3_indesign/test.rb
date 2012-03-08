# Include hook code here
require 'osx/cocoa'
require File.dirname(__FILE__) + '/lib/p3_indesign'
require File.dirname(__FILE__) + '/lib/p3_indesign_library' 
require File.dirname(__FILE__) + '/lib/p3_indesign_import' 
require File.dirname(__FILE__) + '/lib/p3_indesign_export' 
require File.dirname(__FILE__) + '/lib/p3_indesign_p3s_v1'
require File.dirname(__FILE__) + '/lib/p3_indesign_p3s_v1_lang'
require File.dirname(__FILE__) + '/lib/p3s_v1_lang_writeout'
require File.dirname(__FILE__) + '/lib/p3_indesign_coreimg'
require File.dirname(__FILE__) + '/lib/p3_indesign_logger'
require File.dirname(__FILE__) + '/lib/p3_xmlparser'
require File.dirname(__FILE__) + '/lib/p3_hrparser'

require 'rubygems'
require 'appscript' 
#require 'YAML'
gem 'activesupport', '= 2.0.2'
require 'activesupport'
require 'base64'

RAILS_ROOT 	= '/Users/machinist/REFx/REFx3000_11009_ravas'
outputDir 	= File.join(ENV['HOME'],'Desktop/test')
#testFile	= File.expand_path(File.dirname(__FILE__)) + '/indd-testfiles/brochure_def.indd'
testFile	= '/fileadmin/davfree/brProd/brochure_def.indd'
indd 		= P3Indesign.new('', outputDir, testFile, outputDir, 'Adobe InDesign CS4',  true)

#indd.getXML
#puts indd.getXML
#puts indd.getPreview

testfile = File.dirname(__FILE__) +'/basexml.txt' 

unEncoded = ""

if(File.exists?(testfile) && File.readable?(testfile) && File.file?(testfile)) 
	File.open(testfile, 'r') do |fl|
		while(line = fl.gets)
			unEncoded += line
		end
	end
end

p
baseEncoded = Base64.encode64(unEncoded)
#baseEncoded = unEncoded

puts indd.getFinalPreview(baseEncoded,'', false,false)

#wo = P3s_v1_lang_writeout.new()
#p wo.writeout
