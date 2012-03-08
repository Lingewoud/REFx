
class P3HrParser	
	def initialize
		@output = "Analysis of your document:\n"
    end
	
	public
	
	def convertHr(arr)
		layercount = 0
		
		arr[:layerGroups].each do |layergroup|
			if(layergroup[1].length > 1) 
				@output += "	Your document contains 1 layergroup consisting of #{layergroup[1].length} layers. \n" 
			else
				layercount += 1	
			end
		end
		@output += "	Your document contains #{layercount} ungrouped layers. \n" 
		
		layerProp = Hash.new
		
		arr[:layerGroups].each do |layergroup|
			layergroup[1].each do |layer|
				layerProp[":k#{layer[1][:zindex].to_s}"]			= Hash.new
				layerProp[":k#{layer[1][:zindex].to_s}"][:name]		= layer[1][:name]
				layerProp[":k#{layer[1][:zindex].to_s}"][:childs]	= layer[1][:layerChilds]
			end
		end
		
		@output += "\n"
		
		layerProp.sort
				
		layerProp.each do |key, val|
			@output += "	layer '#{val[:name]}' contains:\n"
			getObjects(val[:childs])
		end
		
		return @output
	end
	
	private
	
	def getObjects(objects)
		text			= 0
		undefined		= 0
		eps				= 0
		rectangle		= 0
		textInput		= 0
		imageInput		= 0
		colorInput		= 0
		mergeTextField	= 0
		mergeImageField	= 0
		ti_labels		= ''
		ii_labels		= ''
		ci_labels		= ''
		mtf_labels		= ''
		mif_label		= ''
		
		objects.each do |object|
			if (object[1][:type].downcase == 'text')
				text += 1
			elsif (object[1][:type].downcase == 'undefined')
				undefined += 1
			elsif (object[1][:type].downcase == 'eps')
				eps += 1
			elsif (object[1][:type].downcase == 'rectangle')
				rectangle += 0
			end
			
			if(object[1][:label].index('textInput') != nil)
			p object[1][:label]
				textInput	+= 1
				ti_labels	+= "#{object[1][:label]}, "
			elsif(object[1][:label].index('imageInput') != nil)
				imageInput += 1
				ii_labels += "#{object[1][:label]}, "
			elsif(object[1][:label].index('colorInput') != nil)
				colorInput += 1
				ci_labels += "#{object[1][:label]}, "
			elsif(object[1][:label].index('mergeTextField') != nil)
				mergeTextField += 1
				mtf_labels += "#{object[1][:label]}, "
			elsif(object[1][:label].index('mergeImageField') != nil)
				mergeImageField += 1
				mif_labels += "#{object[1][:label]}, "
			end
		end
		
		@output += (text > 0) ?			"		#{text} objects of type 'text'\n" : ""
		@output += (eps > 0) ?			"		#{eps} objects of type 'eps'\n" : ""
		@output += (rectangle > 0) ?	"		#{rectangle} objects of type 'rectangle'\n" : ""
		@output += (undefined > 0) ?	"		#{undefined} objects of type 'undefined'\n" : ""
		
		@output += (text == 0 && eps == 0 && rectangle == 0 && undefined == 0) ? "		0 objects\n" : ""
		
		@output += (textInput == 0 && imageInput == 0 && colorInput == 0 && mergeTextField == 0 && mergeImageField == 0) ? "" : "\n	Of which are:\n"
		
		@output += (textInput > 0)			?	"		#{textInput} textInputs with labels #{ti_labels.to_s[0, ti_labels.length-2]}\n" : ""
		@output += (imageInput > 0)			?	"		#{imageInput} imageInputs with labels #{ii_labels.to_s[0, ii_labels.length-2]}\n" : ""
		@output += (colorInput > 0)			?	"		#{colorInput} colorInputs with labels #{ci_labels.to_s[0, ci_labels.length-2]}\n" : ""
		@output += (mergeTextField > 0)		?	"		#{mergeTextField} mergeTextFields with labels #{mtf_labels.to_s[0, mtf_labels.length-2]}\n" : ""
		@output += (mergeImageField > 0)	?	"		#{mergeImageField} mergeImageFields with labels #{mif_labels.to_s[0, mif_labels.length-2]}\n" : ""
		
		@output += "\n"		
	end
end	
