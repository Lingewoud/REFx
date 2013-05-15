class P3Banner_library
	
	include Appscript
    
	def initialize(filePath, relPath, outputPath, idApp)
		@filePath		= filePath
		@relPath		= relPath
		@outputPath		= outputPath
		@idApp			= idApp
        
		P3libLogger::log('Using file', @filePath)
		P3libLogger::log('Using outputPath', @outputPath)
		P3libLogger::log('Using relPath', @relPath)
		P3libLogger::log('Using Indesign Version', @idApp.to_s)
	end
end