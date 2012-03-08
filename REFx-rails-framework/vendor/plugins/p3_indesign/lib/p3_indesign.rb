require 'fileutils'
require 'rubygems'
require 'appscript' 
require 'base64'

class P3Indesign

	include Appscript

	# Reads the main configuration arguments of the PAS3 Indesign Engine
	def initialize(jobId,remoteDummyRootDir, relSrcFilePath, relOutputBasePath, inApplication='Adobe InDesign CS4',dryRun=true, noObjectExport=false)
		
		#@logger.info Time.now.to_s+': starting new job: test;'
		#baseDecode params
		remoteDummyRootDir = Base64.decode64(remoteDummyRootDir)
		relSrcFilePath = Base64.decode64(relSrcFilePath)
		relOutputBasePath = Base64.decode64(relOutputBasePath)

		# 'Adobe InDesign CS3'
		# 'Adobe InDesign CS4'
		# 'InDesignServer'
		#
		@idApp			= (inApplication == 'Adobe InDesign CS4') ?  app(inApplication) : app(Base64.decode64(inApplication))
		@dryRun			= dryRun
		@noObjectExport = noObjectExport 

		if remoteDummyRootDir.nil? 
			@AbsSrcFilePath	=  relSrcFilePath
		else 
			@AbsSrcFilePath	=  File.join(remoteDummyRootDir,relSrcFilePath)
			@remoteDummyRootDir = remoteDummyRootDir
			$remoteDummyRootDir = remoteDummyRootDir # Not, nice but needed for getting images in de indesign_import class
		end

		if jobId.nil?
			@relOutputPath 	= relOutputBasePath + '/'
		else
			@jobId = jobId
			@relOutputPath 	= File.join(relOutputBasePath,@jobId) + '/'
		end

		@absOutputPath 		= File.join(@remoteDummyRootDir,relOutputBasePath,@jobId)

		FileUtils.mkdir(@absOutputPath) if not File.directory? @absOutputPath if not dryRun

		@absOutputPath 	+= '/'
	end

	public
	
	# function for testing connection
	def testMe()
		return 'hello'
	end

	def testCreatePdfFolder(relFolderPath)
		absOutputPath 	= File.join(@remoteDummyRootDir,relFolderPath,@jobId)
		relOutputPath 	= File.join(relFolderPath,@jobId)
		FileUtils.mkdir(absOutputPath) if not File.directory? absOutputPath 
		return relOutputPath
	end

	# called by the indexing function. 
	#
	# Returns xml to be used and also safes files in the output paths
	def getXML
		export = P3Indesign_export.new(@AbsSrcFilePath,  @relOutputPath,  @absOutputPath, @idApp)
		export.setNoObjectExport() if @noObjectExport
		export.setDryRun() if @dryRun
		return export.getXML
	end

	def getHumanReadable
		export = P3Indesign_export.new(@AbsSrcFilePath,  @relOutputPath,  @absOutputPath, @idApp)
		export.setNoObjectExport() if @noObjectExport
		export.setDryRun() if @dryRun
		return export.getHumanReadable
	end

	def certifyDocument(pdfName, cpdfName, input, output, error)
		pdfIn		= File.join(Base64.decode64(input), Base64.decode64(cpdfName).to_s[0..-11] + @jobId + '_cert.pdf')
		pdfOut		= File.join(Base64.decode64(output), Base64.decode64(cpdfName).to_s[0..-11] + @jobId + '_cert.pdf')
		pdfError	= File.join(Base64.decode64(error), Base64.decode64(cpdfName)).to_s[0..-11] + @jobId + '_cert_log.pdf'
		pdfFile 	= File.join(@remoteDummyRootDir, Base64.decode64(pdfName))
		cpdfFile 	= File.join(@absOutputPath, Base64.decode64(cpdfName))
		logFile 	= File.join(@absOutputPath, Base64.decode64(cpdfName).to_s[0..-5] + '_log.pdf')
		npdfFile	= File.join(@absOutputPath, Base64.decode64(pdfName).to_s[Base64.decode64(pdfName).rindex('/')..-1])

		begin
			FileUtils.cp(pdfFile, pdfIn)
		rescue Exception => e
			puts e
		end

		begin 
			FileUtils.mkdir(@absOutputPath) if not File.directory? @absOutputPath 
		rescue Exception => e
			puts e
		end

		if(checkCpdfStatus(pdfIn, 0))
		   begin
			   FileUtils.cp(pdfOut, cpdfFile)
		   rescue  Exception => e
			   puts e
			   begin
				   FileUtils.cp(pdfError, logFile)
			   rescue  Exception => err
				   puts err
				   return 'UERR'
			   end
		   end

		   begin
			   FileUtils.cp(pdfFile,  npdfFile)
		   rescue Exception => e
			   puts e
		   end

		   return 'DONE'
		else
			return 'UERR'
		end
	end

	def checkCpdfStatus(pdf, count)
		if(count < 30)
			sleep(1)
			if(File.file? pdf)
				return checkCpdfStatus(pdf, count+1)
			else
				return true
			end
		else
			return false
		end
	end

	def renderFinalPdf(xmlencoded, pdfPreset, outputBaseName, genSwf=false, copyIndd=false)
		import = P3Indesign_import.new(@AbsSrcFilePath, @relOutputPath, @absOutputPath, @idApp)
		return import.renderPdf(xmlencoded, pdfPreset, outputBaseName, genSwf, copyIndd)
	end
	
	def renderPreviewJpg(xmlencoded, outputBaseName)
		import = P3Indesign_import.new(@AbsSrcFilePath,  @relOutputPath,  @absOutputPath, @idApp)
		return import.renderJpg(xmlencoded,outputBaseName)
	end
end
