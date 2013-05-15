class P3Banner_export < P3Banner_library
    
	def initialize(filePath, relPath, outputPath, idApp)
		super(filePath,  relPath,  outputPath, idApp)
        
		@xml		= P3BannerXMLParser.new()
		@hr			= P3BannerHrParser.new()
        
	end
end
