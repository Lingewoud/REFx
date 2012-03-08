
class OSX::NSImage
	def writePNG(filename)
		bits = OSX::NSBitmapImageRep.alloc.initWithData(self.TIFFRepresentation)
		data = bits.representationUsingType_properties(OSX::NSPNGFileType, nil)
		data.writeToFile_atomically(filename, false)
	end
end

class P3Indesignfranchise_coreimg

	public 

	def epsToPng(source,dest)
		image = OSX::NSImage.alloc.initWithContentsOfFile(source)
		
		if image.nil?
			p "error eps does not exist or could not be opened:"+source
		else
			image.writePNG(dest) 
		end
	end

	def cropBitmap(source,dest,w,h)
		os_version = `uname -r`
		if os_version =~ /^8/
			# Tiger
			cropBitmap104(source,dest,w,h)
		elsif os_version =~ /^9/
			# Leopard
			cropBitmap105(source,dest,w,h)
		elsif os_version =~ /^10/
			# Snow Leopard
			cropBitmap105(source,dest,w,h)
		elsif os_version =~ /^11/
			# Lion
			cropBitmap105(source,dest,w,h)
		end
	end

	def cropBitmap105(source,dest,w,h)
		image = OSX::CIImage.alloc.initWithContentsOfURL(OSX::NSURL.fileURLWithPath(source))
		if image.nil?
			p "error eps does not exist or could not be opened:"+source
		else
			original_size = image.extent.size

			new_y= (original_size.height-h)

			croprect = OSX::CGRectMake(0,new_y,w,h)
			imageCropped = image.imageByCroppingToRect(croprect)

			format = OSX::NSPNGFileType
			properties = nil

			bitmapRep = OSX::NSBitmapImageRep.alloc.initWithCIImage(imageCropped)
			blob = bitmapRep.representationUsingType_properties(format, properties)
			blob.writeToFile_atomically(dest, false)
		end
	end
	
	def cropBitmap104(source,dest,w,h)

		#		p source
		#       p dest
		system('cp '+ source+' '+ dest)
		return 
		
		image = OSX::NSImage.alloc.initWithContentsOfURL(OSX::NSURL.fileURLWithPath(source))
		if image.nil?
			p "error eps does not exist or could not be opened:"+source
		else
			original_size = image.extent.size

			new_y= (original_size.height-h)

			croprect = OSX::CGRectMake(0,new_y,w,h)
			imageCropped = image.imageByCroppingToRect(croprect)

			format = OSX::NSPNGFileType
			properties = nil

			bitmapRep = OSX::NSBitmapImageRep.alloc.initWithCIImage(imageCropped)
			blob = bitmapRep.representationUsingType_properties(format, properties)
			blob.writeToFile_atomically(dest, false)
		end
	end

	private
	
	def log(key,val, type = 'info')
		(class << P3Indesignfranchise_logger; P3Indesignfranchise_logger; end).log(key, val, type)
	end


end
app = OSX::NSApplication.sharedApplication
