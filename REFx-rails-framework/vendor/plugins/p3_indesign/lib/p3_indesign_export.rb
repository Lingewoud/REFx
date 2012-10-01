class P3Indesign_export < P3Indesign_library

	def initialize(filePath,  relPath,  outputPath, idApp)
		super(filePath,  relPath,  outputPath, idApp)

		@xml		= P3XMLParser.new()
		@hr			= P3HrParser.new()
	end

	public

	# when @noObjectExport is set, only the pages are exported to bitmaps. 
	# Else all single objects are exported to separate butmaps
	def setNoObjectExport
        P3libLogger::log('Set noObjectExport')
		@noObjectExport = true
	end
	
	# When dryrun is set no bitmaps are exported.
	def setDryRun
		@dryrun	= true
	end
	
	#TODO test functions spreads
	def getXML 

		#TODO REMOVE
		closeAllDocsNoSave

		@idDoc = openDoc(@filePath)

		meta 					= getMetaData()
		@p3s 					= P3Indesign_p3s_v1.new(meta)

		template				= @p3s.parseP3S("template", "template")
		document				= @p3s.parseP3S("document", "document")

		@use 					= (document[:p3s_use]) ? document[:p3s_use] : "FE"

		document[:preview]		= @relPath+'page_1_1.png'
		document[:width]		= getDimensionInPixels(@idDoc.document_preferences.page_width.get)
		document[:height]		= getDimensionInPixels(@idDoc.document_preferences.page_height.get)
		document[:spread_count]	= @idDoc.spreads.get.length
		document[:page_count]	= @idDoc.pages.get.length	
		document[:templates] 	= getTemplates

		#TODO REMOVE 2 LINES
		#closeDoc(@idDoc)
		#return @xml.convertXML(document, true)

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

	#finds all in document defined templates and creates the nodes for the xml definition
	#
	# * return hash to be used in xml
	def getTemplates
		template_hash 	= Hash.new
		index		 	= 0

		@idDoc.layers.get.each do |layer|

			tplLayerName = layer.name.get.to_s.downcase
			if(tplLayerName[0, 3].downcase == 'tp:') then
				
				#TODO compare template layer names lowercase
				template_hash[tplLayerName[3,tplLayerName.length]] = @p3s.parseP3S("template[#{tplLayerName[3,tplLayerName.length]}]", "template")

				groups = template_hash[tplLayerName[3,tplLayerName.length]][:p3s_groups]
				stacks = template_hash[tplLayerName[3,tplLayerName.length]][:p3s_stacks]
	
				layer_hash			= Hash.new{|hash, key| hash[key] = Hash.new}

				_layer_hash 					= Hash.new
				_layer_hash[0] 					= layer_hash
				_layer_hash[1] 					= layer_hash
				_layer_hash[1][:layerID] 		= layer.id_.get
				_layer_hash[1][:name]			= layer.name.get.to_s
				_layer_hash[1][:layerChilds]	= Hash.new
				_layer_hash[1][:layerChilds] 	= getChilds(@idDoc.pages[1].id_.get,layer.id_.get)
				_layer_hash[1][:layerChilds] 	= getGroups(groups, _layer_hash)
			    _layer_hash[1][:layerChilds] 	= getStacks(stacks, _layer_hash)
	
				template_hash[tplLayerName[3,tplLayerName.length]] = Hash.new
				template_hash[tplLayerName[3,tplLayerName.length]][:templateChilds] = Hash.new
				template_hash[tplLayerName[3,tplLayerName.length]][:templateChilds] = _layer_hash[0][:layerChilds]
			end
		end

		return template_hash
	end

	def getSpreads
		spread_hash = Hash.new	

		@idDoc.spreads.get.each do |spread|
			
			spread_id 	= spread.id_.get
			spread_name	= eval(':spread'+spread_id.to_s)

			spread_hash[spread_name]				= @p3s.parseP3S("spread[#{spread.index.get}]", "spread")
			spread_hash[spread_name][:id] 			= spread_id
			spread_hash[spread_name][:index] 		= spread.index.get
			spread_hash[spread_name][:pages] 		= Hash.new
			spread_hash[spread_name][:page_count]	= spread.pages.get.length
		end

		return spread_hash
	end

	def getPages(spread)
		page_hash = Hash.new

		@idDoc.spreads[its.id_.eq(spread)].pages.get.each do |page|
			page_id		= page.id_.get 
			page_name 	= eval(':page'+page_id.to_s)
			
			page_hash[page_name]				= @p3s.parseP3S("page[#{page.document_offset.get}]", "page")
			page_hash[page_name][:id]			= page_id
			page_hash[page_name][:sourceId]		= page_id
			#page_hash[page_name][:index]		= page.index.get
			page_hash[page_name][:side]			= page.side.get.to_s[0,page.side.get.to_s.index('_')]
			page_hash[page_name][:layerGroups]	= Hash.new
			page_hash[page_name][:preview]		= @relPath+'page_'+page.parent.index.get.to_s+'_'+page.index.get.to_s+'.png'
		end

		return page_hash
	end

	def getLayerGroups(page)
		layerGroups = Hash.new
		layers		= getLayers(page)
		lastLayer	= ''
		spread_nr	= @idDoc.pages[its.id_.eq(page)].parent.index.get.to_s
		page_nr		= @idDoc.pages[its.id_.eq(page)].index.get.to_s

		unlock(@idDoc)  
		setEpsExportOptions(@idDoc.pages[its.id_.eq(page)].document_offset.get.to_s)

		layers.each do |layer|
			layerId = layer[:name].to_s[0, 2]

			if(lastLayer == layerId)
				exportLayer(layer, spread_nr, page_nr)
			end

			if(lastLayer == layerId || layerId.downcase == 'xx' || layerId.downcase == 'tp') 
				@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].visible, :to => false)
			else
				@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].visible, :to => true)
			end

			lastLayer = layerId

			if(layerGroups.keys.to_s.index('group' + layerId) == nil) then layerGroups[eval(':group' + layerId)] = Hash.new end
			layerGroups[eval(':group' + layerId)][eval(':layer'+layer[:layerID].to_s)] = layer			
		end

		# add a new layer so there's always something to export
		nwLyr = @idDoc.make(:new => :layer)
		nwObj = @idDoc.pages[its.id_.eq(page)].make(:new => :text_frame)
		nwObj.geometric_bounds.set(['6p', '6p', '18p', '18p'])
		nwObj.move(:to => [5,5])
		nwObj.contents.set("Preview")
		nwObj.characters.fill_color.set(:to => "Paper")
		nwObj.characters.applied_font.set(:to => "Verdana")
		nwObj.characters.font_style.set(:to => "Bold")
		nwObj.characters.point_size.set(:to => 18)

		page_base_name = @outputPath+'page_'+spread_nr+'_'+page_nr
		
        pixWidth	= getDimensionInPixels(getDimensionInPixels(@idDoc.document_preferences.page_width.get))
		pixHeight	= getDimensionInPixels(getDimensionInPixels(@idDoc.document_preferences.page_height.get))

		#exportPNGviaEPS(@idDoc, page_base_name+'.eps', page_base_name+'.png', pixWidth, pixHeight)
        P3libIndesign::exportToPNG(@idApp, @idDoc, @outputPath, page_base_name+'.pdf', page_base_name+'.png', pixWidth, pixHeight)


		# and delete it because there's no further use
		nwObj.delete()
		nwLyr.delete()

		return layerGroups
	end

	def getLayers(page)
		i 			= 0
		items		= getPageItems(page)
		spread_nr	= @idDoc.pages[its.id_.eq(page)].parent.index.get.to_s
		page_nr		= @idDoc.pages[its.id_.eq(page)].index.get.to_s

		layer_arr  = Array.new

		@idDoc.layers.get.each do |layer|
			if(items.include?(layer.id_.get)) then
				
				layer_hash	= Hash.new{|hash, key| hash[key] = Hash.new}

				layer_hash[:layerID]		= layer.id_.get
				layer_hash[:name]			= layer.name.get.to_s
				layer_hash[:zindex]			= @idDoc.layers.get.length-i
				layer_hash[:preview]		= @relPath+'page_'+spread_nr+'_'+page_nr+'_layer'+layer.id_.get.to_s+'.png'
				layer_hash[:layerChilds] 	= Hash.new

				layer_arr << layer_hash
				i += 1
			end
		end
		return layer_arr
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

			#check for unmapped groupchilds
			_ret_hash.each do | _chgroup |

				if(_chgroup[1][:type] == "group")
					_chgroup[1][:grp_content].each do | _chchild|
						label = _chchild[1][:label]
						_tmp = @p3s.parseP3S(label, label.to_s[0, label.index('_')])
						if(_tmp.empty?)
                            
                            P3libLogger::log('WARNING:', 'child in group: +  _chgroup[0] + with label: '+ label +' is has no mapping')
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

	def getCurrentLayerGroup(currLayer)
		layerCount = 0

		@idDoc.layers.get.each do |layer|
			if(layer.name.get.to_s[0, 2] == currLayer) then  layerCount += 1 end
		end

		return layerCount
	end


	def getPageItems(page)
		items_arr = Array.new

		@idDoc.pages[its.id_.eq(page)].all_page_items.get.each do |item|
			items_arr  << item.item_layer.id_.get
		end

		return items_arr
	end

	#  Get stacks on layer on page	
	#  * stacks hash containing stacks definitions
	#  * layer hash containing one layer with layer hash keys
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

	# Get child objects on layer on page
	#
	# * page page_id @idDoc.pages[1].id_.get,
	# * layer layer_id for example @idDoc.layers[1].id_.get
	#
	def getChilds(page, layer)
		childs = Hash.new{|hash, key| hash[key] = Array.new}
		page_item_arr = Array.new
		page_item_arr = @idDoc.pages[its.id_.eq(page)].page_items.get

		@idDoc.layers[its.id_.eq(layer)].page_items.get.each do |child|
			if(page_item_arr.include?(child)) then

				#FIXME add support for tables
				#FIXME add support for ovals, polygons, and graphic lines

				geom 						=  child.geometric_bounds.get

				id							= child.id_.get
				name						= child.get
				label						= child.label.get.to_s
				type						= getType(child)
				width						= geom[3].to_f-geom[1].to_f
				height						= geom[2].to_f-geom[0].to_f
				static						= getStatic(child.label.get.to_s.downcase)
				lyr							= @idDoc.layers[its.id_.eq(layer)]
				layer_name					= lyr.name.get

				if(label.index('_') == nil)
					childProps 				= Hash.new{|hash, key| hash[key] = Array.new}
				else
					childProps				= @p3s.parseP3S(label, label.to_s[0, label.index('_')])
					childProps[:p3s_use]	= (!childProps[:p3s_use])? @use : childProps[:p3s_use]
				end

                P3libLogger::log('exporting ' + type.to_s + ' - ' + id.to_s + ' - ' + label.to_s)

				childProps[:objectID]		= id
				childProps[:label]			= label
				childProps[:type]			= type
				childProps[:x]				= getDimensionInPixels(geom[1])
				childProps[:y]				= getDimensionInPixels(geom[0])
				childProps[:w]				= getDimensionInPixels(width)
				childProps[:h]				= getDimensionInPixels(height)
				childProps[:isStatic]		= static
				childProps[:inGroup]		= (getCurrentLayerGroup(layer_name.to_s[2, 2]) > 1) ? true : false
				childProps[:content] 	   	= getContent(name, type, static)
				childProps[:group]			= layer_name.to_s[0, 2]
				childProps[:preview]		= exportObject(id, name, type, width, height, geom[1], geom[2], lyr) 

				#FIXME indesign/appscript gives very 'special' output in case of Pantone colors - ignore for now
			   childProps[:background] 		= 'unknown'  #getBackGroundColor(child)  
			   childs['child'+id.to_s] 		= childProps 
			   
                P3libLogger::log('exported')
			end
		end

		return childs
	end

	def getStatic(label)
		#NOTE rTextInput & MergertextField = rich text
		#NOTE all types need an order indication according to the convention _001
		#NOTE mergeTextField need to have an identifier after the order indicator e.g. _003_namefield

		types		= ['text', 'image', 'color', 'stack', 'group', 'object', 'slot'] 
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

		if(child.label.get.to_s.downcase[0,4] == 'slot')
			type = 'slot'
		elsif(child.class_.get.to_s == 'rectangle')
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

		#return '#' + toHex(r) + toHex(g) + toHex(b)
	end

	def exportLayer(layer, spread_nr, page_nr)
		@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].visible, :to => true)

		layer_base_name = @outputPath+'page_'+spread_nr+'_'+page_nr+'_layer'+layer[:layerID].to_s
		pixWidth	= getDimensionInPixels(getDimensionInPixels(@idDoc.document_preferences.page_width.get))
		pixHeight	= getDimensionInPixels(getDimensionInPixels(@idDoc.document_preferences.page_height.get))

		#exportPNGviaEPS(@idDoc, layer_base_name+'.eps', layer_base_name+'.png', pixWidth, pixHeight)
        P3libIndesign::exportToPNG(@idApp, @idDoc, @outputPath, layer_base_name+'.pdf', layer_base_name+'.png', pixWidth, pixHeight)

		@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].visible, :to => false)
	end

	def exportObject(object, name, type, width, height, x, y, lyr)
		nwidth	= (width < 30) ? 30 : width
		nheight = (height < 30) ? 30 : height

		orig	= @outputPath+type.to_s+object.to_s
		#dest	= @outputPath+type.to_s+object.to_s+'.png'

		if (@noObjectExport == true)
			return
		end

		if(!@dryrun)

			tmpDoc = @idApp.make(:new => :document)
			tmpDoc.document_preferences.set(tmpDoc.document_preferences.page_width, :to => nwidth)
			tmpDoc.document_preferences.set(tmpDoc.document_preferences.page_height, :to => nheight)

			@idApp.active_document.set(@idDoc)
			@idDoc.set(@idDoc.selection, :to => name)
			@idApp.copy()

			@idApp.active_document.set(tmpDoc)
			@idApp.paste()
			@idApp.selection.move(:to => [0, 0])
			
			pixWidth	= getDimensionInPixels(width)
			pixHeight	= getDimensionInPixels(height)

			#exportPNGviaEPS(tmpDoc, orig, dest, pixWidth, pixHeight)
            P3libIndesign::exportToPNG(@idApp, tmpDoc, @outputPath, orig+'.pdf', orig+'.png', pixWidth, pixHeight)

			tmpDoc.close(:saving => :no)
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

	def toHex(color)
		if(color < 0) then color = 0 end
		return color.round.to_s(16)
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
