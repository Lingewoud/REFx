require 'fileutils'
require 'rubygems'
require 'appscript'
require 'base64'

class P3Banner
    
	include Appscript
    
	# Reads the main configuration arguments of the PAS3 Indesign Engine
	def initialize(jobId,remoteDummyRootDir, relSrcFilePath, relOutputBasePath, inApplication='Adobe Flash CS6',dryRun=true, noObjectExport=false)
        
        P3libLogger::log('Hello, i am a FLASH BANNER')
        P3libLogger::log('Doing some init stuff...')
        
        remoteDummyRootDir = Base64.decode64(remoteDummyRootDir)
		relSrcFilePath = Base64.decode64(relSrcFilePath)
		relOutputBasePath = Base64.decode64(relOutputBasePath)
        
        P3libLogger::log('init:')
        P3libLogger::log(remoteDummyRootDir)
        P3libLogger::log(relOutputBasePath)
        P3libLogger::log(relSrcFilePath)
        
		# 'Adobe Flash CS3'
		# 'Adobe Flash CS4'
		# 'InDesignServer'
		#
        
		@idApp			= (inApplication == 'Adobe Flash CS6') ?  app(inApplication) : app(Base64.decode64(inApplication)) #dit gaat zeer wss mis, want ik heb geen flash.
		@dryRun			= dryRun
		@noObjectExport = noObjectExport
        
		if remoteDummyRootDir.nil?
			@AbsSrcFilePath	=  relSrcFilePath
            else
			@AbsSrcFilePath	=  File.join(remoteDummyRootDir,relSrcFilePath)
			@remoteDummyRootDir = remoteDummyRootDir
			$remoteDummyRootDir = remoteDummyRootDir # Not, nice but needed for getting images in de banner_import class
		end
        
		if jobId.nil?
			@relOutputPath 	= relOutputBasePath + '/'
            else
			@jobId = jobId
			@relOutputPath 	= File.join(relOutputBasePath,@jobId) + '/'
		end
        
        modConfigJSFL()
        
		@absOutputPath 		= File.join(@remoteDummyRootDir,relOutputBasePath,@jobId)
        
		FileUtils.mkdir(@absOutputPath) if not File.directory? @absOutputPath if not dryRun
        
		@absOutputPath 	+= '/'
        
        P3libLogger::log('Hello, init seemingly succeeded')
    end

    def modConfigJSFL()
        
        path = '/Users/maartenvanhees/Source/GitHub/REFx3/REFx-rails-framework/JSFL_export/export/export.jsfl'

        lines = IO.readlines(path).map do |line|

        end        
        
        #File.open(path, 'w') do |file|
        #    P3libLogger::log(file)
        #end
        
    end
    
    def indexFile()
        path = "#{RAILS_ROOT}/JSFL_export/export/export.jsfl"
        cmd = "osascript -e 'tell application \"Adobe Flash CS6\" to open \"#{RAILS_ROOT}/JSFL_export/export/export.jsfl\"'"
                P3libLogger::log(path)
        #system(cmd)
        
        P3libLogger::log(cmd)
        
    end
    
    def getXML()
        
        file = File.open("/Users/maartenvanhees/XMLDUMMY.xml", "rb")
        contents = file.read
        
        return contents
        
    end
end
