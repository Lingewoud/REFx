# P3libImage
#TODO REMOVE
#require 'osxfix'

## library for all helper image classes

class P3libImage
    
    public
    
    def getXYRatio(original_size,newWidth, newHeight)
        return newWidth.to_f / original_size.width.to_f, newHeight.to_f / original_size.height.to_f
    end

    def self.resizeBitmap(img,pixWidth,pixHeight)
    #return
        #cmd = "/opt/local/bin/convert -units PixelsPerInch -density 72x72 -crop #{pixWidth}x#{pixHeight}+0+0 #{img} #{img}"
        cmd = "#{RAILS_ROOT}/../p3imgutils/p3scale -w#{pixWidth} -h#{pixHeight} -i #{img} -o #{img}"
        #P3libLogger::log("resizing cmd:",cmd)
        system(cmd)
    end

    def self.resizeBitmapByWidth(img,pixWidth)
        cmd = "#{RAILS_ROOT}/../p3imgutils/p3scale -w#{pixWidth} -h0 -i #{img} -o #{img}"
        #P3libLogger::log("resizing cmd:",cmd)
        system(cmd)
    end

    def self.trimAlphaFromImage(inImage,outImage)
        cmd = "#{RAILS_ROOT}/../p3imgutils/p3trimalpha -i #{inImage} -o #{outImage}"

        #P3libLogger::log("trimming alpha to :",outImage)
        system(cmd)
    end

end

