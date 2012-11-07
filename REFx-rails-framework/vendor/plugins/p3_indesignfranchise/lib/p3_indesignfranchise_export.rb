#--
# Copyright (c) 2010-2012 Lingewoud BV
#
# This script analyzes an InDesign Document creating a Guide Asset
#
#++

require 'base64'


class P3Indesignfranchise_export < P3Indesignfranchise_library

	def initialize(filePath,  relPath,  outputPath, idApp)
		super(filePath,  relPath,  outputPath, idApp)

		@xml		= P3XMLParser.new()
		@hr			= P3HrParser.new()
	end

	public

    def getXMLB64 #test functions spreads
        return Base64.encode64(getXML)
    end

    
	def getXML #test functions spreads
        if($debug)
            P3libLogger::log('Debug mode for P3Indesignfranchise_export', 'on')
        end
            
        closeAllDocsNoSave

		@idDoc = openDoc(@filePath)

		meta 					= getMetaData()
		@p3s 					= P3Indesignfranchise_p3s_v1.new(meta)

		document				= @p3s.parseP3S("document", "document")

		@use = (document[:p3s_use]) ? document[:p3s_use] : "FE"

		document[:preview]		= @relPath+'page_1_1.png'
		document[:width]		= getDimensionInPixels(@idDoc.document_preferences.page_width.get)
		document[:height]		= getDimensionInPixels(@idDoc.document_preferences.page_height.get)
		document[:spread_count]	= @idDoc.spreads.get.length
		document[:page_count]	= @idDoc.pages.get.length	
		document[:spreads] 		= getSpreads

		#get pages of spreads
		document[:spreads].each do |spreads|
			spreads[1][:pages] 	= getPages(spreads[1][:id])

			spreads[1][:pages].each do |page|
				if(page[1].key?(:p3s_order))
					@page_order = page[1][:p3s_order]
				end

				if(page[1].key?(:p3s_groups))
					groups 		= page[1][:p3s_groups]
				else
					groups 		= false
				end

				if(page[1].key?(:p3s_stacks))
					stacks 		= page[1][:p3s_stacks]
				else
					stacks 		= false
				end

				#delete all arrays of page so the XML won't be littered with extra nodes
				page[1].each do |key, val|
					if(val.class == Array) then 
						page[1].delete(key) 
					end
				end

				#get layers and group them
				P3libLogger::log('get/exporting layerFroup', '')
				page[1][:layerGroups] = getLayerGroups(page[1][:id])

				page[1][:layerGroups].each do |layerGroup|

					#get items per page per layergroup per layer
					layerGroup[1].each do |layer|	
						layer[1][:layerChilds] = getChilds(page[1][:id], layer[1][:layerID])
						layer[1][:layerChilds] = getGroups(groups, layer)
						layer[1][:layerChilds] = getStacks(stacks, layer)
					end
				end

				@page_order 	= nil
			end
		end

		closeDoc(@idDoc)

		P3libLogger::log('Removing eps and pdf files','')

		return @xml.convertXML(document, true)
	end

	def getHumanReadable
		@idDoc = openDoc(@filePath)
		dryRun(true)

		page_count 				= 0
		document 				= Hash.new

		document[:preview]		= @relPath+'sourcedoc.png'
		document[:width]		= getDimensionInPixels(@idDoc.document_preferences.page_width.get)
		document[:height]		= getDimensionInPixels(@idDoc.document_preferences.page_height.get)
		document[:spreads] 		= getSpreads

		#get pages of spreads
		document[:spreads].each do |spreads|
			spreads[1][:pages] 	= getPages(spreads[1][:id])

			spreads[1][:pages].each do |page|

				#get layers and group them
				page[1][:layerGroups] = getLayerGroups(page[1][:id])

				page[1][:layerGroups].each do |layerGroup|

					#get items per page per layergroup per layer
					layerGroup[1].each do |layer|
						layer[1][:layerChilds] = getChilds(page[1][:id], layer[1][:layerID])
					end
				end
				page_count		+= 1
			end

			spreads[1][:page_count]	= spreads[1][:pages].length
		end

		document[:spread_count]		=	document[:spreads].length
		document[:page_count]		=	page_count
		document[:meta]				= 	'container for metadata (TS)/should be a hash' 

		closeDoc(@idDoc)

		return @hr.convertHr(document)
	end

	private

	def getMetaData()
		result = ""

		# get embedded metadata
		@idDoc.layers.get.each do |layer|
			if(layer.name.get.to_s[0, 2].downcase == 'xx') then
				layer.page_items.get.each do |child|
					if(child.label.get.to_s.downcase == 'p3s') then
						object 	= child.get
						@idDoc.get(object.lines.object_reference, :result_type => :list).each do |line|
							result += @idDoc.get(line, :result_type => :string)
						end
					end
				end
			end
		end

		# get metadata form file
		metafile = @filePath.to_s[0..-5]+'txt' 

		if(File.exists?(metafile) && File.readable?(metafile) && File.file?(metafile)) 
			File.open(metafile, 'r') do |fl|
				while(line = fl.gets)
					result += line.gsub(/(^|[\n])/, "\r")
				end
			end
		end

		return result
	end

	def getGroups(groups, layer)
		_ret_hash = Hash.new
		_in_group = Array.new

		if(groups)
			if(groups[0].class == Array)
				groups.each do |group|
					layer[1][:layerChilds].each do |lc|
						if(lc[1].key?(:label) && lc[1][:label] != "")
							ret = getGroup(group, lc[1][:label])
							if(ret)
								if(!_ret_hash.key?(eval(":grp_#{ret}")))
									_ret_hash[eval(":grp_#{ret}")] 				= @p3s.parseP3S(ret, "group")
									_ret_hash[eval(":grp_#{ret}")][:label] 		= "group_"+ret
									_ret_hash[eval(":grp_#{ret}")][:objectID]	= ret
									_ret_hash[eval(":grp_#{ret}")][:type]		= "group"
									_ret_hash[eval(":grp_#{ret}")][:inGroup]	= lc[1][:inGroup]
									_ret_hash[eval(":grp_#{ret}")][:group]		= lc[1][:group]
									_ret_hash[eval(":grp_#{ret}")][:p3s_use]	= lc[1][:p3s_use]
									_ret_hash[eval(":grp_#{ret}")][:isStatic]	= lc[1][:isStatic]
									_ret_hash[eval(":grp_#{ret}")][:grp_content]= Hash.new
								end
								_ret_hash[eval(":grp_#{ret}")][:grp_content][eval(":#{lc[0]}")] = lc[1] 
								_in_group << lc[0]
							else
								_ret_hash[eval(":#{lc[0]}")] = lc[1]
							end
						end
					end
				end
			else
				layer[1][:layerChilds].each do |lc|
					if(lc[1].key?(:label) && lc[1][:label] != "")
						ret = getGroup(groups, lc[1][:label])
						if(ret)
							if(!_ret_hash.key?(eval(":grp_#{ret}")))
								_ret_hash[eval(":grp_#{ret}")] = @p3s.parseP3S(ret, "group")
								_ret_hash[eval(":grp_#{ret}")][:label] 		= "group_" +ret
								_ret_hash[eval(":grp_#{ret}")][:objectID]	= ret
								_ret_hash[eval(":grp_#{ret}")][:type]		= "group"
								_ret_hash[eval(":grp_#{ret}")][:inGroup]	= lc[1][:inGroup]
								_ret_hash[eval(":grp_#{ret}")][:group]		= lc[1][:group]
								_ret_hash[eval(":grp_#{ret}")][:p3s_use]	= lc[1][:p3s_use]
								_ret_hash[eval(":grp_#{ret}")][:isStatic]	= lc[1][:isStatic]	
								_ret_hash[eval(":grp_#{ret}")][:grp_content]= Hash.new	
							end
							_ret_hash[eval(":grp_#{ret}")][:grp_content][eval(":#{lc[0]}")] = lc[1]
							_in_group << lc[0]
						else
							_ret_hash[eval(":#{lc[0]}")] = lc[1]
						end
					end
				end
			end
			_ret_hash = cleanUpStacksAndGroups(_ret_hash, _in_group)
			return _ret_hash	
		else
			return layer[1][:layerChilds]
		end
	end

	def	getGroup(group, label)
		if(group[1].include?(label))
			return group[0]
		else
			return false
		end
	end

	def getStacks(stacks, layer)
		_ret_hash = Hash.new
		_in_stack = Array.new

		if(stacks)
			if(stacks[0].class == Array)
				stacks.each do |stack|
					layer[1][:layerChilds].each do |lc|
						if(lc[1].key?(:label) && lc[1][:label] != "")
							ret = getStack(stack, lc[1][:label])
							if(ret)
								if(!_ret_hash.key?(eval(":stck_#{ret}")))
									_ret_hash[eval(":stck_#{ret}")] = @p3s.parseP3S(ret, "stack")
									_ret_hash[eval(":stck_#{ret}")][:label] 	= "stack_"+ret
									_ret_hash[eval(":stck_#{ret}")][:objectID]	= ret
									_ret_hash[eval(":stck_#{ret}")][:type]		= "stack"
									_ret_hash[eval(":stck_#{ret}")][:inGroup]	= lc[1][:inGroup]
									_ret_hash[eval(":stck_#{ret}")][:group]		= lc[1][:group]
									_ret_hash[eval(":stck_#{ret}")][:p3s_use]	= lc[1][:p3s_use]
									_ret_hash[eval(":stck_#{ret}")][:isStatic]	= lc[1][:isStatic]
									_ret_hash[eval(":stck_#{ret}")][:stck_content]	= Hash.new
								end
								_ret_hash[eval(":stck_#{ret}")][:stck_content][eval(":#{lc[0]}")] = lc[1]
								_in_stack << lc[0]
							else
								_ret_hash[eval(":#{lc[0]}")] = lc[1]
							end
						end
					end
				end
			else
				layer[1][:layerChilds].each do |lc|
					if(lc[1].key?(:label) && lc[1][:label] != "")
						ret = getStack(stacks, lc[1][:label])
						if(ret)
							if(!_ret_hash.key?(eval(":stck_#{ret}")))
								_ret_hash[eval(":stck_#{ret}")] = @p3s.parseP3S(ret, "stack")
								_ret_hash[eval(":stck_#{ret}")][:label] 	= "stack_"+ret
								_ret_hash[eval(":stck_#{ret}")][:objectID]	= ret
								_ret_hash[eval(":stck_#{ret}")][:type]		= "stack"
								_ret_hash[eval(":stck_#{ret}")][:inGroup]	= lc[1][:inGroup]
								_ret_hash[eval(":stck_#{ret}")][:group]		= lc[1][:group]
								_ret_hash[eval(":stck_#{ret}")][:p3s_use]	= lc[1][:p3s_use]
								_ret_hash[eval(":stck_#{ret}")][:isStatic]	= lc[1][:isStatic]
								_ret_hash[eval(":stck_#{ret}")][:stck_content]	 = Hash.new
							end
							_ret_hash[eval(":stck_#{ret}")][:stck_content][eval(":#{lc[0]}")] = lc[1]
							_in_stack << lc[0]
						else
							_ret_hash[eval(":#{lc[0]}")] = lc[1]
						end
					end
				end
			end
			_ret_hash = cleanUpStacksAndGroups(_ret_hash, _in_stack)
			return _ret_hash	
		else
			return layer[1][:layerChilds]
		end
	end

	def	getStack(stack, label)
		if(stack[1] == label||"group_"+stack[1] == label)
			return stack[0]
		else
			return false
		end
	end

	def removegetObjectZindexArray(pageId)
		@idDoc.pages.get.each do |page|
			@pageitems = getPageItems(page.id_.get)
		end

		@pageitems.each do |item|
			p item
		end
	end

	def getChilds(pageId, layerId)
	
		layerObj 	= @idDoc.layers[its.id_.eq(layerId)]
		layer_name 	= layerObj.name.get
		layerGroup	= layer_name.to_s[0, 2]
		inGroup		= (countLayersInLayerGroup(layer_name.to_s[2, 2]) > 1) ? true : false #??? waarom [2,2]

		childs = Hash.new{|hash, key| hash[key] = Array.new}

		page_item_arr = Array.new
		page_item_arr = @idDoc.pages[its.id_.eq(pageId)].page_items.get

        #P3libLogger::log('walk through page items on page with ID', pageId.to_s)
		P3libLogger::log('walk through page items on layer', layer_name.to_s)
		pageItemIdx = 0
		page_item_arr.each do |child|
			#if(page_item_arr.include?(child)) then
			if(child.item_layer.id_.get==layerId) then

				#FIXME add support for tables
				#FIXME add support for ovals, polygons, and graphic lines

				geom 						= child.geometric_bounds.get
				id							= child.id_.get
				name						= child.get
				index						= child.index.get
				label						= child.label.get.to_s
				type						= getType(child)
				width						= geom[3].to_f-geom[1].to_f
				height						= geom[2].to_f-geom[0].to_f
				static						= getStatic(child.label.get.to_s.downcase)

				if(label.index('_') == nil)
					childProps 				= Hash.new{|hash, key| hash[key] = Array.new}
				else
					childProps				= @p3s.parseP3S(label, label.to_s[0, label.index('_')])
					childProps[:p3s_use]	= (!childProps[:p3s_use])? @use : childProps[:p3s_use]
				end

				childProps[:objectID]		= id
				childProps[:label]			= label
				childProps[:index]			= index 
				childProps[:pageItemIndex]	= pageItemIdx += 1
				childProps[:type]			= type
				childProps[:x]				= getDimensionInPixels(geom[1])
				childProps[:y]				= getDimensionInPixels(geom[0])
				childProps[:w]				= getDimensionInPixels(width)
				childProps[:h]				= getDimensionInPixels(height)
				childProps[:isStatic]		= static
				childProps[:inGroup]		= inGroup
				childProps[:content] 	   	= getContent(name, type, static)
				childProps[:group]			= layerGroup
				childProps[:preview]		= exportObject(id, name, type, width, height, geom[1], geom[2], layerObj)

				#FIXME indesign/appscript gives very 'special' output in case of Pantone colors - ignore for now
			   childProps[:background] 		= 'unknown'  #getBackGroundColor(child)  

			   childs['child'+id.to_s] 		= childProps 
			end
		end

		return childs
	end


	def getStatic(label)
		#NOTE rTextInput & MergertextField = rich text
		#NOTE all types need an order indication according to the convention _001
		#NOTE mergeTextField need to have an identifier after the order indicator e.g. _003_namefield

		types		= ['text', 'image', 'color', 'stack', 'group', 'object'] 
		isStatic	= true

		types.each do |type|

			if label.index(type) != nil
				isStatic = false
				break 
			else
				isStatic = true
			end
		end

		return isStatic
	end

	def getType(child)
		#FIXME add support for ovals, polygons, and graphic lines

		if(child.class_.get.to_s == 'rectangle')
			#FIXME add support for multiple images in rectangles
			type = (child.graphics.get.length == 1) ? child.graphics.class_.get.to_s : 'rectangle'
		elsif(child.class_.get.to_s == 'text_frame')
			type = 'text'
		else 
			type = 'undefined'
		end

		return type
	end

	def getContent(object, type, static)

		if(type == 'text' && static == false)
			content="<content>\n<![CDATA["
			lineI = 0

			lines = @idDoc.get(object.lines.object_reference, :result_type => :list)

			lines.each do |line|
				#FIXME add font color
				lineID			= 'line_'+@idDoc.get(object.id_, :result_type => :string).to_s + '_' + lineI.to_s
				font			= @idDoc.get(line.applied_font, :result_type => :string).to_s
				spacing			= @idDoc.get(line.desired_letter_spacing).to_s
				fontScale		= @idDoc.get(line.desired_glyph_scaling).to_i
				fontStyle		= (@idDoc.get(line.font_style, :result_type => :string).to_s == 'Italic') ? 'italic' : 'normal'
				fontWeight		= (@idDoc.get(line.font_style, :result_type => :string).to_s == 'Bold') ? 'bold' : 'normal'
				justify			= @idDoc.get(line.justification, :result_type => :string).to_s
				fontSize		= @idDoc.get(line.point_size, :result_type => :string).to_s

				justification	= (justify != 'center') ? justify.to_s[0,justify.index('_')] : 'center'
				cnt				= (@idDoc.get(line, :result_type => :string).to_s[-1	,1].chomp.empty? || @idDoc.get(line, :result_type => :string).to_s[-1	,1] == ' ') ? @idDoc.get(line, :result_type => :string).chomp : @idDoc.get(line, :result_type => :string)

				if lineI < 1
					content	+= "<p id=\"#{lineID}\" style=\"font-family:#{font};font-size:#{fontSize};text-align:#{justification};font-style:#{fontStyle};font-weight:#{fontWeight};letter-spacing:#{spacing};font-size:#{fontScale}%\">#{cnt}<br/>"
				else
					content	+= "#{cnt}<br/>"
				end

				lineI += 1

			end	

			content += "</p><br/>]]>\n</content>"
		else
			content	= "<content>\nfalse\n</content>"
		end

		return content
	end


	def getBackGroundColor(child)
		#FIXME possibly Indesign supports multiple color spaces, for now, presume it's always CMYK
		if(child.fill_color.class_.get.to_s == 'color')

			puts child.fill_color.space.get
			return getCMYKtoHeX(child.fill_color.color_value.get.to_s)
		else
			return 'none'
		end
	end

	def getCMYKtoHeX(cmyk)
		#FIXME somehow this seems not as accurate as the ActionScript equivalent
		
		colorArr = cmyk.split('.')
		puts cmyk
		c = stripLeadingZero(colorArr[0]).to_f/100
		m = stripLeadingZero(colorArr[1]).to_f/100
		y = stripLeadingZero(colorArr[2]).to_f/100
		k = stripLeadingZero(colorArr[3]).to_f/100

		#the adobe approach
		ra = (1.0 - min(1.0, c + k))*255
		ga = (1.0 - min(1.0, m + k))*255
		ba = (1.0 - min(1.0, y + k))*255

		#a custom interpretation
		rc = (1.0 - (c * (1.0 - k) + k))*255
		gc = (1.0 - (m * (1.0 - k) + k))*255
		bc = (1.0 - (y * (1.0 - k) + k))*255

		#another approach
		ro = ((1.0 - k + c)*(k - 1.0))*255
		go = ((1.0 - k + m)*(k - 1.0))*255
		bo = ((1.0 - k + y)*(k - 1.0))*255
	end

	def exportLayer(layer, spread_nr, page_nr)

		@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].visible, :to => true)

		layer_base_name = @outputPath+'page_'+spread_nr+'_'+page_nr+'_layer'+layer[:layerID].to_s

		orig	= layer_base_name+'.pdf'
		dest	= layer_base_name+'.png'

		pixWidth	= getDimensionInPixels(getDimensionInPixels(@idDoc.document_preferences.page_width.get))
		pixHeight	= getDimensionInPixels(getDimensionInPixels(@idDoc.document_preferences.page_height.get))

		P3libLogger::log('exporting layer', layer_base_name)
        P3libIndesign::exportToPNG(@idApp, @idDoc, @outputPath, orig, dest, pixWidth, pixHeight)        
		P3libImage::trimAlphaFromImage(dest,File.dirname(dest)+'/trimmed_'+File.basename(dest))

		if not File.exists?( File.dirname(dest)+'/trimmed_'+File.basename(dest))
			P3libLogger::log('convert cannot remove alpha, just copying', '')
			cmd = "cp #{dest} #{File.dirname(dest)+'/trimmed_'+File.basename(dest)}"
			system(cmd)
		end
        #remove org
        #cmd2 = "rm #{dest}"
		#system(cmd2)
        
		@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].visible, :to => false)
	end

	def exportObject(object, name, type, width, height, x, y, lyr)
		nwidth	= (width < 1) ? 1 : width
		nheight = (height < 1) ? 1 : height

		orig	= @outputPath+type.to_s+object.to_s + '.pdf'
		dest	= @outputPath+type.to_s+object.to_s + '.png'
		P3libLogger::log('exporting object of type: ' , type)
		P3libLogger::log('  object width: ' , nwidth.to_s)
		P3libLogger::log('  object height: ' , nheight.to_s)

		if(!@dryrun)

            tmpDoc = @idApp.make(:new => :document, :with_properties => {
                               :document_preferences => {
                               :column_gutter => 0,
                               :document_bleed_top_offset => 0,
                               :facing_pages => false,
                               :page_width => nwidth,
                               :page_height => nheight
                               }
            })

			@idApp.active_document.set(@idDoc)
			@idDoc.set(@idDoc.selection, :to => name)

			@idApp.copy()

			@idApp.active_document.set(tmpDoc)
			@idApp.paste()
            
            tmpDoc.align(tmpDoc, :align_option => :horizontal_centers, :align_distribute_bounds => :page_bounds, :align_distribute_items => [@idApp.selection])
            tmpDoc.align(tmpDoc, :align_option => :vertical_centers, :align_distribute_bounds => :page_bounds, :align_distribute_items => [@idApp.selection])
			pixWidth	= getDimensionInPixels(width)
			pixHeight	= getDimensionInPixels(height)

            P3libIndesign::exportToPNG(@idApp, tmpDoc, @outputPath, orig, dest, pixWidth, pixHeight)

            if $debug.nil? || $debug == false
                tmpDoc.close(:saving => :no)
            end
            
		end
		return @relPath+type.to_s+object.to_s+'.png'
	end

			
	def stripLeadingZero(string)
		if (string[0,1] == '0' && string.length > 1) 
			return stripLeadingZero(string[1..-1])
		else
			return string
		end	
	end

	def min(a,b)
		return a <= b ? a : b
	end

	def cleanUpStacksAndGroups(_ret, _doubles)
		_doubles.each do |key|
			if(_ret.key?(eval(":#{key}"))) 
				_ret.delete(eval(":#{key}"))
			end
		end
		return _ret
	end
end 
