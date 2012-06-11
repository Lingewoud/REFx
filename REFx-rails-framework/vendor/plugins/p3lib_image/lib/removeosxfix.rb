require 'rubygems'
require 'osx/cocoa'
require 'active_support'

#OSX FIX
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
	end
end
