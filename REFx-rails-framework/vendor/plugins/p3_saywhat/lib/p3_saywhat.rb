# P3Saywhat

require 'rubygems'
require 'appscript' 
require 'base64'
require 'osax'

class P3Saywhat         
    include Appscript
    
    def initialize(jobId,remoteDummyRootDir, relSrcFilePath, relOutputBasePath)
		
        remoteDummyRootDir = Base64.decode64(remoteDummyRootDir)
        #		relSrcFilePath = Base64.decode64(relSrcFilePath)
		relOutputBasePath = Base64.decode64(relOutputBasePath)
		
		if remoteDummyRootDir.nil? 
            #	@AbsSrcFilePath	=  relSrcFilePath
            else 
			#@AbsSrcFilePath	=  File.join(remoteDummyRootDir,relSrcFilePath)
			$remoteDummyRootDir= remoteDummyRootDir
		end
        
		if jobId.nil?
			@relOutputPath 		= relOutputBasePath + '/'
            else
			$jobId = jobId
			@relOutputPath 		= File.join(relOutputBasePath,jobId) + '/'
		end
        
		@absOutputPath 	= File.join(remoteDummyRootDir,relOutputBasePath,jobId)
        
		#FileUtils.mkdir(@absOutputPath) if not File.directory? @absOutputPath if not dryRun
        
		@absOutputPath 	+= '/'
        p @absOutputPath
        
    end
    
    # function for testing connection
    def say(what64,voice64)
        what = Base64.decode64(what64)
        voice = Base64.decode64(voice64)
        
        osax = OSAX.osax
        osax.say(what,:using=>voice)
        osax.say(what,:using=>voice, :saving_to =>'/Users/pim/Desktop/Audio.aiff')
        return what
    end     
end