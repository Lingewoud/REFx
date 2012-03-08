# Include hook code here
require 'osx/cocoa'
require File.dirname(__FILE__) + '/lib/p3_indesign'
require File.dirname(__FILE__) + '/lib/p3_indesign_library' 
require File.dirname(__FILE__) + '/lib/p3_indesign_import' 
require File.dirname(__FILE__) + '/lib/p3_indesign_export' 
require File.dirname(__FILE__) + '/lib/p3_indesign_p3s_v1'
require File.dirname(__FILE__) + '/lib/p3_indesign_p3s_v1_lang'
require File.dirname(__FILE__) + '/lib/p3_indesign_coreimg'
#require File.dirname(__FILE__) + '/lib/p3_indesign_logger'
require File.dirname(__FILE__) + '/lib/p3_xmlparser'
require File.dirname(__FILE__) + '/lib/p3_hrparser'

require 'rubygems'
require 'appscript' 
#require 'YAML'
require 'activesupport'
require 'base64'
include Appscript

RAILS_ROOT 	= '../../../'


class  P3Indesign_logger
	class << self
		def log(key, val, type)
			return
			if(@logger.nil?) then
				@logger 		= Logger.new("#{RAILS_ROOT}/log/pas3.log")
				@logger.level 	= Logger::DEBUG
			end

			case type
			when 'info'
				@logger.info Time.now.to_s+' - '+ key+ ': '+ val
			when 'error'
				@logger.error Time.now.to_s+' - '+ key+ ': '+ val
			when 'warn'
				@logger.warn Time.now.to_s+' - '+ key+ ': '+ val
			when 'fatal'
				@logger.fatal Time.now.to_s+' - '+ key+ ': '+ val
			when 'unknown'
				@logger.unknown Time.now.to_s+' - '+ key+ ': '+ val
			when 'debug'
				@logger.debug Time.now.to_s+' - '+ key+ ': '+ val
			end
		end
	end
end

class  Testing < P3Indesign_import

	def initialize(filePath,  relPath,  outputPath, inApplication)
		@idApp          = app(inApplication)
		@filePath		= filePath
		@relPath		= relPath
		@outputPath		= outputPath

		log('Using file', @filePath)
		log('Using outputPath', @outputPath)
		log('Using relPath', @relPath)
		log('Using Indesign Version', @idApp.to_s)


		@outputPath=outputPath

	end
	
	def test
		#createindesignTempDestDoc()            
		@indesignTempDestDoc = @idApp.make(:new => :document)

		myFrame = @idApp.documents[1].pages[1].make(:new => :text_frame)
		myFrame.geometric_bounds.set(['6p', '6p', '18p', '18p'])
		myFrame.contents.set("I\xC3\xB1t\xC3\xABrn\xC3\xA2tiz\xC3\xA6ti\xC3\xB8n")

#		pageCopy = @indesignTempDestDoc.pages[0].duplicate()
#		pageCopy = @indesignTempDestDoc.pages[0].duplicate()
#		pageCopy = @indesignTempDestDoc.pages[0].duplicate(:to => @indesignTempDestDoc.pages[-1])
		destPage = @indesignTempDestDoc.pages.get.length
		pageCopy = @indesignTempDestDoc.pages[1].duplicate(:to => @indesignTempDestDoc.pages[destPage])

		destJPGDir  = @outputPath+'PAS3-Jpeg'
		destJPGFilePath = @outputPath+'PAS3-Jpeg/PAS3.jpg'                                                                                                                                                                  
		p destJPGDir
		p destJPGFilePath 


		p 'set options'   
		setJpegExportOptions(':all')                                                                                                                                                                                        

		p 'export'
		exportJPEG(@indesignTempDestDoc,destJPGFilePath)   
	end

end

AbsSrcFilePath ='/Volumes/ravas/ravas-pas3-20dec2010/web/dummy/fileadmin/pas3/indesignSrcDocs/RavasLeafletOriginal/Ravas iFork Leaflet Stramien.indd'
absOutputPath ='/Volumes/ravas/ravas-pas3-20dec2010/web/dummy/fileadmin/pas3/pdfpage/313/'
relOutputPath ='fileadmin/pas3/pdfpage/313/'

testing = Testing.new(AbsSrcFilePath,  relOutputPath,  absOutputPath, 'Adobe InDesign CS4')
testing.closeAllDocsNoSave
testing.test()



