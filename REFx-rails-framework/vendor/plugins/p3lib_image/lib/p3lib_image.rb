# P3libImage
require 'osxfix'

## library for all helper image classes

class P3libImage

    def getXYRatio(original_size,newWidth, newHeight)
#        original_size = origCIImage.extent.size
       return newWidth.to_f / original_size.width.to_f, newHeight.to_f / original_size.height.to_f
    end

	def vector(x, y, w, h)
		OSX::CIVector.vectorWithX_Y_Z_W(x, y, w, h)
	end
end

