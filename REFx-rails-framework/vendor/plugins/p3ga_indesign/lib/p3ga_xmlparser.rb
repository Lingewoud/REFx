class P3gaXMLParser	
	def initialize
		@output = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    end
	
	public
	
	def convertXML(arr, extended = false)
		@extended = extended
		@output += translate('document', arr)
		return @output
	end
	
	private
	
	def translate(descr, arr)
		cnt = ''
		node = ''
		ret = ''
		
		arr.each do | key, val|
			if key.to_s == 'content'
				if(@extended)
					node = val.to_s
				end
			elsif val.class != Hash && val.class != Array
				cnt += "#{key}=\"#{val.to_s}\" "
			elsif key == nil || val == nil
				puts key.to_s
				puts val.to_s
			else
				node += translate(key, val)
			end
		end
		
		if node != ''
			ret	+= "<#{descr} #{cnt}>\n"
			ret	+= "#{node}\n"
			ret += "</#{descr}>\n"
		else
			ret	+= "<#{descr} #{cnt}/>\n"
		end

		return ret

	end
end	