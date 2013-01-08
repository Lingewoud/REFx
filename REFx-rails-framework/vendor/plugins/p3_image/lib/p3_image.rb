require 'fileutils'
# P3Image
#
class P3Image
    
	def initialize(jobId,remoteDummyRootDir, relSrcFilePath, relOutputBasePath)
		remoteDummyRootDir = Base64.decode64(remoteDummyRootDir)
		relSrcFilePath = Base64.decode64(relSrcFilePath)
		relOutputBasePath = Base64.decode64(relOutputBasePath)
        
		p remoteDummyRootDir
		p relSrcFilePath
		p relOutputBasePath
        
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
        
		#tmp normalized path
		@tmpFile = '/tmp/'+ P3libUtil::helper_newtempname(5) +File.extname(@AbsSrcFilePath)
		p @tmpFile
		FileUtils.cp(@AbsSrcFilePath, @tmpFile)
        
		@absOutputPath 	= File.join(remoteDummyRootDir,relOutputBasePath,jobId)
        
        
		FileUtils.mkdir(@absOutputPath) if not File.directory? @absOutputPath
        
		@absOutputPath 	+= '/'
	end
    
	# public functions
	public
    
    def convertToPng()
        P3libLogger::log('converting to png', @AbsSrcFilePath)
        #        P3libIndesign::exportToPNG(@idApp, @idDoc, @outputPath, orig, dest, pixWidth, pixHeight)
        #		P3libImage::trimAlphaFromImage(dest,File.dirname(dest)+'/trimmed_'+File.basename(dest))
        outfile = File.join(@absOutputPath,File.basename(@AbsSrcFilePath)+'.png')
        P3libImage::convertImgToFiletype(@AbsSrcFilePath,outfile,'png');
		#data.writeToFile_atomically(File.join(@absOutputPath,File.basename(@AbsSrcFilePath)+'.png'), false)
        
    end
    
	def convertToBitMap(targetFileType,maxW,maxH)
        
        targetFileType = Base64.decode64(targetFileType)
        P3libLogger::log('converting to targetFileType', targetFileType)
        outfile = File.join(@absOutputPath,File.basename(@AbsSrcFilePath)+'.png')
        P3libImage::convertImgToFiletype(@AbsSrcFilePath,outfile,'png');
        
        P3libLogger::log('using max width', maxW.to_s)
        P3libLogger::log('using max height', maxH.to_s)
        P3libImage::resizeBitmap(outfile,maxW,maxH)
        P3libLogger::log('output file:', outfile)
        
        return outfile
    end
end