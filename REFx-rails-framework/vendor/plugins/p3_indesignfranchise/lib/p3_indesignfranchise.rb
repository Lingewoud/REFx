require 'fileutils'
require 'rubygems'
require 'appscript' 

class P3Indesignfranchise

	include Appscript

	def initialize(jobId,remoteDummyRootDir, relSrcFilePath, relOutputBasePath, inApplication='Adobe InDesign CS4',dryRun=true)

		# 'Adobe InDesign CS3'
		# 'Adobe InDesign CS4'
		# 'InDesignServer'
		#
		remoteDummyRootDir = Base64.decode64(remoteDummyRootDir)
		relSrcFilePath = Base64.decode64(relSrcFilePath)
		relOutputBasePath = Base64.decode64(relOutputBasePath)
		
		@idApp          = (inApplication == 'Adobe InDesign CS4') ?  app(inApplication) : app(Base64.decode64(inApplication))
		@dryRun			= dryRun

		if remoteDummyRootDir.nil? 
			@AbsSrcFilePath	=  relSrcFilePath
		else 
			@AbsSrcFilePath	=  File.join(remoteDummyRootDir,relSrcFilePath)
			$remoteDummyRootDir= remoteDummyRootDir
		end

		if jobId.nil?
			@relOutputPath 		= relOutputBasePath + '/'
		else
			$jobId = jobId
			@relOutputPath 		= File.join(relOutputBasePath,jobId) + '/'
		end

		@absOutputPath 	= File.join(remoteDummyRootDir,relOutputBasePath,jobId)

		FileUtils.mkdir(@absOutputPath) if not File.directory? @absOutputPath if not dryRun

		@absOutputPath 	+= '/'
	end

	# public functions
	public

	def testMe()
		return 'hello'
	end

	def testCreatePdfFolder(relFolderPath)
		absOutputPath 	= File.join($remoteDummyRootDir,relFolderPath,$jobId)
		relOutputPath 	= File.join(relFolderPath,$jobId)
		FileUtils.mkdir(absOutputPath) if not File.directory? absOutputPath 
		return relOutputPath
	end

	def getXML
		export = P3Indesignfranchise_export.new(@AbsSrcFilePath,  @relOutputPath,  @absOutputPath, @idApp)
		export.setDryRun() if @dryRun
		#return export.getXMLB64

        return export.getXML
	end

	def getXMLB64
		export = P3Indesignfranchise_export.new(@AbsSrcFilePath,  @relOutputPath,  @absOutputPath, @idApp)
		export.setDryRun() if @dryRun
		return export.getXMLB64
	end
    
    
	def getHumanReadable
		export = P3Indesignfranchise_export.new(@AbsSrcFilePath,  @relOutputPath,  @absOutputPath, @idApp)
		export.setDryRun() if @dryRun
		return export.getHumanReadable
	end
	
	def getFinalPreview(xmlencoded, preset, relFolderPath2='', genSwf=false, copyIndd=false)
		import = P3Indesignfranchise_import.new(@AbsSrcFilePath,  @relOutputPath,  @absOutputPath, @idApp)
		import.setDryRun() if @dryRun
		return import.getFinalPreview(xmlencoded, preset, relFolderPath2, genSwf, copyIndd )
	end

	def certifyDocument(pdfIn,pdfOut,pitstopInputFolder, pitstopSuccesFolder,pitstopErrorFolder)
		import = P3Indesignfranchise_import.new(@AbsSrcFilePath,  @relOutputPath,  @absOutputPath, @idApp)
		import.setDryRun() if @dryRun
		return import.certifyDocument(pdfIn,pdfOut,pitstopInputFolder,pitstopSuccesFolder,pitstopErrorFolder)
	end
end
