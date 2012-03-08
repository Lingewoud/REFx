require "processor.rb"
path_to_image = '/Users/pimsnel/Desktop/RubyGemstone.jpg'

p = RedArtisan::CoreImage::Processor.new OSX::CIImage.from(path_to_image)
p.resize(240, 180)
p.render do |result|
	  result.save('/Users/pimsnel/Desktop/resized.jpg', OSX::NSJPEGFileType)
end
