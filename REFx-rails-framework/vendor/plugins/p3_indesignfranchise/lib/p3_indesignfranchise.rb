require 'fileutils'
require 'rubygems'
require 'appscript' 

class P3Indesignfranchise

	include Appscript

	def initialize(jobId,remoteDummyRootDir, relSrcFilePath, relOutputBasePath, inApplication='Adobe InDesign CS4',dryRun=true, typo3BaseUrl=nil,voucherKey=nil)

		# 'Adobe InDesign CS3'
		# 'Adobe InDesign CS4'
		# 'Adobe InDesign CS6'
		# 'InDesignServer'
        # These are needed for the Typo3RestServer
        
		@idApp          = (inApplication == 'Adobe InDesign CS4') ?  app(inApplication) : app(Base64.decode64(inApplication))
		@dryRun			= dryRun

        @voucherKey = Base64.decode64(voucherKey) if voucherKey
        @typo3BaseUrl = Base64.decode64(typo3BaseUrl) if typo3BaseUrl
		
		#remote dummy root is the TYPO3 root dir
        remoteDummyRootDir = Base64.decode64(remoteDummyRootDir)
		relSrcFilePath = Base64.decode64(relSrcFilePath)
        relOutputBasePath = Base64.decode64(relOutputBasePath)
        
		if remoteDummyRootDir.nil?
			@AbsSrcFilePath	=  relSrcFilePath
		else 
            @AbsSrcFilePath	=  File.join(remoteDummyRootDir,relSrcFilePath)
			$remoteDummyRootDir= remoteDummyRootDir
		end

		@relOutputPath 		= relOutputBasePath + '/'
		@jobId = jobId

		#this should only be done in the import and cert
		@absOutputPath 	= File.join(remoteDummyRootDir,relOutputBasePath)
		@absOutputPath 	+= '/'
	end

	# public functions
	public

	def testMe()
		return 'hello'
	end

	def testCreatePdfFolder(relFolderPath)
		absOutputPath 	= File.join($remoteDummyRootDir,relFolderPath,@jobId)
		relOutputPath 	= File.join(relFolderPath,@jobId)
		FileUtils.mkdir(absOutputPath) if not File.directory? absOutputPath 
		return relOutputPath
	end

	def getXML
		export = P3Indesignfranchise_export.new(@AbsSrcFilePath,  @relOutputPath,  @absOutputPath, @idApp)
		export.setDryRun() if @dryRun
        return export.getXML
	end

	def getXMLB64
		export = P3Indesignfranchise_export.new(@AbsSrcFilePath,  @relOutputPath,  @absOutputPath, @idApp)
		export.setDryRun() if @dryRun
		return export.getXMLB64
	end
    
	def getHumanReadable
		export = P3Indesignfranchise_export.new(@AbsSrcFilePath,  @relOutputPath,  @absOutputPath, @idApp)
		return export.getHumanReadable
	end
	
	def getFinalPreview(xmlencoded, preset, relFolderPath2='', genSwf=false, copyIndd=false)


		#final preview needs an extra job folder
		@relOutputPath 		= File.join(@relOutputPath,@jobId) + '/'
		@absOutputPath 	= File.join(@absOutputPath,@jobId)
        begin
            FileUtils.mkdir(@absOutputPath) if not File.directory? @absOutputPath if not dryRun
            rescue Exception=>e
            P3libLogger::log('Cannot mkdir. Is the dest dir mounted?' , e.to_s)
        end

		@absOutputPath 	+= '/'

		import = P3Indesignfranchise_import.new(@AbsSrcFilePath,  @relOutputPath,  @absOutputPath, @idApp, @typo3BaseUrl, @voucherKey)
		return import.getFinalPreview(xmlencoded, preset, relFolderPath2, genSwf, copyIndd )
	end

	def certifyDocument(pdfIn,pdfOut,pitstopInputFolder, pitstopSuccesFolder,pitstopErrorFolder)
		import = P3Indesignfranchise_import.new(@AbsSrcFilePath,  @relOutputPath,  @absOutputPath, @idApp)
		return import.certifyDocument(pdfIn,pdfOut,pitstopInputFolder,pitstopSuccesFolder,pitstopErrorFolder)
	end
end
