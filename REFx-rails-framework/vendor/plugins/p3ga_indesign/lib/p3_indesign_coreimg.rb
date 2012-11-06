
class OSX::NSImage
	def writePNG(filename)
		bits = OSX::NSBitmapImageRep.alloc.initWithData(self.TIFFRepresentation)
		data = bits.representationUsingType_properties(OSX::NSPNGFileType, nil)
		data.writeToFile_atomically(filename, false)
	end
end

class P3Indesign_coreimg

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

	private
	
	def log(key,val, type = 'info')
		(class << P3Indesign_logger; P3Indesign_logger; end).log(key, val, type)
	end


end
app = OSX::NSApplication.sharedApplication
