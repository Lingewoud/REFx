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
		@tmpFile = '/tmp/'+helper_newtempname(5)+File.extname(@AbsSrcFilePath)
		p @tmpFile
		FileUtils.cp(@AbsSrcFilePath, @tmpFile)

		@absOutputPath 	= File.join(remoteDummyRootDir,relOutputBasePath,jobId)


		FileUtils.mkdir(@absOutputPath) if not File.directory? @absOutputPath 

		@absOutputPath 	+= '/'
	end

	# public functions
	public

	def convertToPng()

		require 'osx/cocoa'

		psimage = OSX::NSImage.alloc
		psimage.initWithContentsOfFile(@tmpFile)

		bits = OSX::NSBitmapImageRep.alloc.initWithData(psimage.TIFFRepresentation)
		data = bits.representationUsingType_properties(OSX::NSPNGFileType, nil)
		data.writeToFile_atomically(File.join(@absOutputPath,File.basename(@AbsSrcFilePath)+'.png'), false)

		return nil
	end

	def convertToBitMap(targetFileType,maxW,maxH)
		require 'osx/cocoa'
		targetFileType = Base64.decode64(targetFileType)

		targetBaseName = File.basename(@AbsSrcFilePath)+'.'+targetFileType.downcase
		targetRelFilePath =  File.join(@relOutputPath,targetBaseName)
		targetAbsFilePath = File.join(@absOutputPath,targetBaseName)

		case targetFileType
		when "JPEG"
			type = OSX::NSJPEGFileType
#		when "PDF"
#			type = PDF NOT SUPPORTED
		when "PNG"
			type = OSX::NSPNGFileType
		when "TIFF"
			type = OSX::NSTIFFFileType
		end

		psimage = OSX::NSImage.alloc
		psimage.initWithContentsOfFile(@tmpFile)

		original_size = psimage.size
		imglib=P3libImage.new
		testscale_x, testscale_y = imglib.getXYRatio(original_size,maxW, maxH)

		if testscale_y > testscale_x
			maxH = original_size.height * testscale_x
			maxW = original_size.width * testscale_x
		else 
			maxH = original_size.height * testscale_y
			maxW = original_size.width * testscale_y
		end

		psimage.setScalesWhenResized(true)
		psimage.setSize( OSX::NSMakeSize(maxW,maxH))

		bits = OSX::NSBitmapImageRep.alloc.initWithData(psimage.TIFFRepresentation)

		@ciImage = OSX::CIImage. alloc.initWithBitmapImageRep(bits);

		#create_core_image_context(maxW,maxH)  #moet dit voor de veiligheid of is dit overbodig?
		scale_x, scale_y = imglib.getXYRatio(@ciImage.extent.size,maxW, maxH)

		@ciImage.affine_clamp :inputTransform => OSX::NSAffineTransform.transform do |clamped|
			clamped.lanczos_scale_transform :inputScale => scale_x > scale_y ? scale_x : scale_y, :inputAspectRatio => scale_x / scale_y do |scaled|
				scaled.crop :inputRectangle => imglib.vector(0, 0, maxW, maxH) do |cropped|
					@targetImage = cropped
				end
			end
		end

		bitmapRep = OSX::NSBitmapImageRep.alloc.initWithCIImage(@targetImage)
		blob = bitmapRep.representationUsingType_properties(type, nil)

		blob.writeToFile_atomically(targetAbsFilePath, false)

		return targetRelFilePath
	end

		def helper_newtempname(len)
		chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
		newpass = ""
		1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
		return newpass
	end


end
