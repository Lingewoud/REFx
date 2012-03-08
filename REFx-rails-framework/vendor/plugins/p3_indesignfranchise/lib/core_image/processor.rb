require 'rubygems'
require 'osx/cocoa'
require 'active_support'

require File.dirname(__FILE__) + '/filters/scale'
require File.dirname(__FILE__) + '/filters/color'
require File.dirname(__FILE__) + '/filters/watermark'
require File.dirname(__FILE__) + '/filters/quality'
require File.dirname(__FILE__) + '/filters/perspective'
require File.dirname(__FILE__) + '/filters/effects'

# Generic image processor for scaling images based on CoreImage via RubyCocoa.
#
# Example usage:
#
# p = Processor.new OSX::CIImage.from(path_to_image)
# p.resize(640, 480)
# p.render do |result|
#   result.save('resized.jpg', OSX::NSJPEGFileType)
# end
#
# This will resize the image to the given dimensions exactly, if you'd like to ensure that aspect ratio is preserved:
#
# p = Processor.new OSX::CIImage.from(path_to_image)
# p.fit(640)
# p.render do |result|
#   result.save('resized.jpg', OSX::NSJPEGFileType)
# end
#
# fit(size) will attempt its best to resize the image so that the longest width/height (depending on image orientation) will match
# the given size. The second axis will be calculated automatically based on the aspect ratio.
#
# Scaling is performed by first clamping the image so that its external bounds become infinite, this helps when scaling so that any
# rounding discrepencies in dimensions don't affect the resultant image. We then perform a Lanczos transform on the image which scales
# it to the target size. We then crop the image to the traget dimensions.
#
# If you are generating smaller images such as thumbnails where high quality rendering isn't as important, an additional method is
# available:
#
# p = Processor.new OSX::CIImage.from(path_to_image)
# p.thumbnail(100, 100)
# p.render do |result|
#   result.save('resized.jpg', OSX::NSJPEGFileType)
# end
#
# This will perform a straight affine transform and scale the X and Y boundaries to the requested size. Generally, this will be faster
# than a lanczos scale transform, but with a scaling quality trade.
#
# More than welcome to intregrate any patches, improvements - feel free to mail me with ideas.
#
# Thanks to
# * Satoshi Nakagawa for working out that OCObjWrapper needs inclusion when aliasing method_missing on existing OSX::* classes.
# * Vasantha Crabb for general help and inspiration with Cocoa
# * Ben Schwarz for example image data and collaboration during performance testing
#
# Copyright (c) Marcus Crafter <crafterm@redartisan.com> released under the MIT license
#
module RedArtisan
  module CoreImage
    class Processor
  
      def initialize(original)
        if original.respond_to? :to_str
          @original = OSX::CIImage.from(original.to_str)
        else
          @original = original
        end
      end

	  def crop(width, height)
		  create_core_image_context(width, height)

		  original_size = @original.extent.size
		  scale_x, scale_y = scale(original_size.width, original_size.height)

		  @original.affine_clamp :inputTransform => OSX::NSAffineTransform.transform do |clamped|
			  clamped.lanczos_scale_transform :inputScale => scale_x > scale_y ? scale_x : scale_y, :inputAspectRatio => scale_x / scale_y do |scaled|
				  scaled.crop :inputRectangle => vector(0, 0, width, height) do |cropped|
					  @target = cropped
				  end
			  end
		  end
	  end

      def render(&block)
        raise "unprocessed image: #{@original}" unless @target
        block.call @target
      end
      
      include Filters::Scale, Filters::Color, Filters::Watermark, Filters::Quality, Filters::Perspective, Filters::Effects
  
      private
  
        def create_core_image_context(width, height)
      		output = OSX::NSBitmapImageRep.alloc.initWithBitmapDataPlanes_pixelsWide_pixelsHigh_bitsPerSample_samplesPerPixel_hasAlpha_isPlanar_colorSpaceName_bytesPerRow_bitsPerPixel(nil, width, height, 8, 4, true, false, OSX::NSDeviceRGBColorSpace, 0, 0)
      		context = OSX::NSGraphicsContext.graphicsContextWithBitmapImageRep(output)
      		OSX::NSGraphicsContext.setCurrentContext(context)
      		@ci_context = context.CIContext
        end
        
        def vector(x, y, w, h)
          OSX::CIVector.vectorWithX_Y_Z_W(x, y, w, h)
        end
    end
  end
end

module OSX
  class CIImage
    include OCObjWrapper
  
    def method_missing_with_filter_processing(sym, *args, &block)
      f = OSX::CIFilter.filterWithName("CI#{sym.to_s.camelize}")
      return method_missing_without_filter_processing(sym, *args, &block) unless f
    
      f.setDefaults if f.respond_to? :setDefaults
      f.setValue_forKey(self, 'inputImage')
      options = args.last.is_a?(Hash) ? args.last : {}
      options.each { |k, v| f.setValue_forKey(v, k.to_s) }
    
      block.call f.valueForKey('outputImage')
    end
  
    alias_method_chain :method_missing, :filter_processing
      
    def save(target, format = OSX::NSJPEGFileType, properties = nil)
      bitmapRep = OSX::NSBitmapImageRep.alloc.initWithCIImage(self)
      blob = bitmapRep.representationUsingType_properties(format, properties)
      blob.writeToFile_atomically(target, false)
    end
  
    def self.from(filepath)
      raise Errno::ENOENT, "No such file or directory - #{filepath}" unless File.exists?(filepath)
      OSX::CIImage.imageWithContentsOfURL(OSX::NSURL.fileURLWithPath(filepath))
    end
  end
end



