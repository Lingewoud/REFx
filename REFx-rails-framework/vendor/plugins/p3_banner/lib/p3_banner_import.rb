require 'base64'
require 'fileutils'
require 'iconv'

class P3Banner_import < P3Banner_library
    
	def initialize(filePath, relPath, outputPath, idApp)
        
		super(filePath, relPath, outputPath, idApp)
        
        P3libLogger::log('Hello, i am the FLASH BANNER import module, and ive supered some stuff')
        
		@outputPath	= outputPath
	end
end
