require 'base64'
require 'fileutils'

class Hash

	def self.from_xml(xml, preserve_attributes = false)
		# TODO: Refactor this into something much cleaner that doesn't rely on XmlSimple
		typecast_xml_value(undasherize_keys(XmlSimple.xml_in_string(xml,
		'forcearray'   => false,
		'forcecontent' => true,
		'keeproot'     => true,
		'contentkey'   => '__content__')
		), preserve_attributes)
	end

	private

	def self.typecast_xml_value(value, preserve_attributes = false)
		case value.class.to_s
		when 'Hash'
			if value['type'] == 'array'
				child_key, entries = value.detect { |k,v| k != 'type' }   # child_key is throwaway
				if entries.nil? || (c = value['__content__'] && c.blank?)
					[]
				else
					case entries.class.to_s   # something weird with classes not matching here.  maybe singleton methods breaking is_a?
					when "Array"
						entries.collect { |v| typecast_xml_value(v, preserve_attributes) }
					when "Hash"
						[typecast_xml_value(entries, preserve_attributes)]
					else
						raise "can't typecast #{entries.inspect}"
					end
				end
			elsif value.has_key?("__content__")
				content = value["__content__"]
				if parser = XML_PARSING[value["type"]]
					if parser.arity == 2
						XML_PARSING[value["type"]].call(content, value)
					else
						XML_PARSING[value["type"]].call(content)
					end
				elsif preserve_attributes && value.keys.size > 1
					value["content"] = value.delete("__content__")
					value
				else
					content
				end
			elsif value['type'] == 'string' && value['nil'] != 'true'
				""
				# blank or nil parsed values are represented by nil
			elsif value.blank? || value['nil'] == 'true'
				nil
				# If the type is the only element which makes it then 
				# this still makes the value nil, except if type is
				# a XML node(where type['value'] is a Hash)
			elsif value['type'] && value.size == 1 && !value['type'].is_a?(::Hash)
				nil
			else
				xml_value = value.inject({}) do |h,(k,v)|
					h[k] = typecast_xml_value(v, preserve_attributes)
					h
				end

				# Turn { :files => { :file => #<StringIO> } into { :files => #<StringIO> } so it is compatible with
				# how multipart uploaded files from HTML appear
				xml_value["file"].is_a?(StringIO) ? xml_value["file"] : xml_value
			end
		when 'Array'
			value.map! { |i| typecast_xml_value(i, preserve_attributes) }
			case value.length
			when 0 then nil
			when 1 then value.first
			else value
			end
		when 'String'
			value
		else
			raise "can't typecast #{value.class.name} - #{value.inspect}"
		end
	end
end

class P3Indesignfranchise_import < P3Indesignfranchise_library

	def initialize(filePath,  relPath,  outputPath, idApp)
		super(filePath,  relPath,  outputPath, idApp)
		@outputPath=outputPath
	end

	public 

	def getFinalPreview(xmlencoded, preset, relFolderPath='', genSWF=false, copyINDD=false)

		finalPreview(xmlencoded, preset, relFolderPath, genSWF, copyINDD)
	end

	def certifyDocument(pdfIn,pdfOut,pitstopInputFolder,pitstopSuccesFolder,pitstopErrorFolder)

		pdfIn=Base64.decode64(pdfIn)
		pdfOut=Base64.decode64(pdfOut)
		pitstopInputFolder=Base64.decode64(pitstopInputFolder)
		pitstopSuccesFolder=Base64.decode64(pitstopSuccesFolder)
		pitstopErrorFolder=Base64.decode64(pitstopErrorFolder)

		fakeCertify=false
		if fakeCertify
			FileUtils.cp(pdfIn, pdfOut) #fixme use tmp name
			return 'ok'
		end

		#TODO do file exist check
		if pdfIn.nil?
			l('No input file to certitify')
			return 'not ok'
		end

		if pdfOut.nil?
			l('No output file given')
			return 'not ok'
		end

		l('certitifying'+ pdfIn + " to " + pdfOut)

		tmpName	= helper_newtempname(9)+'.pdf'

		FileUtils.cp(pdfIn,  File.join(pitstopInputFolder,tmpName)) #fixme use tmp name

		timeout=1 #timeout tien 5 minuten
		cResult = certifyResult(File.join(pitstopSuccesFolder,tmpName), File.join(pitstopErrorFolder,tmpName), timeout)

		until cResult == true
			sleep(1)
			l('waiting for instantpdf')
			timeout = timeout + 1
			l('TimeOutPos:'+ timeout.to_s)
			cResult = certifyResult(File.join(pitstopSuccesFolder,tmpName), File.join(pitstopErrorFolder,tmpName), timeout)
		end

		if File.exist?(File.join(pitstopSuccesFolder,tmpName))
			l('instantpdf return succes')
			FileUtils.cp(File.join(pitstopSuccesFolder,tmpName), pdfOut)
			return 'ok'
		else
			l('instantpdf return failure')
			return false
		end

		#TODO replace cp with mv 
		#		FileUtils.cp('/Users/server/pitstop/NL/OUT/'+tmpName, pdfOut)
		#		FileUtils.cp('/Users/server/pitstop/NL/ERROR/'+tmpName, pdfOut)

		#copy preview doc to pitstop in with correct naming
		#check for file if it exists  with timeout
	end


	private

	def certifyResult(succesFile,errorFile,timeoutPos)
		if File.exist?(succesFile) or File.exist?(errorFile) or (timeoutPos == 300)
			return true
		else
			return false
		end
	end

	def finalPreview(xmlencoded,preset,relFolderPath='', genSWF=false, copyINDD=false)

        closeAllDocsNoSave
		relFolderPath = Base64.decode64(relFolderPath)
		preset = Base64.decode64(preset)


		xml 		= Base64.decode64(xmlencoded)
		xml 		= Base64.decode64(xml)

		P3libLogger::log("Starting final preview","") 
		#P3libLogger::log('decoded',xml)


		@finalHash 	= Hash.from_xml(xml,true)

		P3libLogger::log("open template doc",'')
		@idDoc = openDoc(@filePath)
		P3libLogger::log("creating dest doc",'')
		createDoc

		P3libLogger::log("creating spreads",'')
		createSpreads()

		#closeDoc(@idDoc)

		allVisible(@finalDoc)

		FileUtils.mkdir_p @outputPath

		genPDF=true
		if genPDF
			destpdf	= @outputPath+'PAS3-Print.pdf'
			exec_exportPDF(@finalDoc,destpdf,preset)
		end

		#TODO make option
		genPNG = true
		if genPNG
			destPngFile	= @outputPath+'PAS3-Screen.png'
			exec_exportPNG(@finalDoc, destPngFile)
		end

		if genSWF
			destSwfFilePath	= @outputPath+'PAS3-Flash/PAS3-Flash.swf'
			exec_setSwfDefaultOptions
			exec_exportSWF(@finalDoc, destSwfFilePath)
		end

		if copyINDD
			packPath=@outputPath+'PAS3-Pack'
			exec_exportPackedINDD(doc,packPath)
		end

		#closeDoc(@finalDoc)
	end

	def createDoc

		#		@finalDoc = @idApp.make(:new => :document,:with_properties => {:page_width => @idDoc.document_preferences.page_width.get.to_s+"mm", :page_height => @idDoc.document_preferences.page_height.get.to_s+"mm"})

		origWidth = @idDoc.document_preferences.page_width.get.to_s+"mm"
		origHeight = @idDoc.document_preferences.page_height.get.to_s+"mm"

		@finalDoc = @idApp.make(:new => :document,:with_properties => {:document_preferences => {:page_width => origWidth, :page_height => origHeight}})

		@finalDoc.document_preferences.facing_pages.set( :to  =>  @idDoc.document_preferences.facing_pages.get  )

		# remove disable object style to prevend unwanted styles
		@finalDoc.object_styles["[Basic Text Frame]"].enable_stroke.set( :to  => false )
		@finalDoc.object_styles["[Basic Text Frame]"].enable_fill.set( :to  => false )
		@finalDoc.object_styles["[Basic Text Frame]"].enable_stroke_and_corner_options.set( :to  => false )
		@finalDoc.object_styles["[Basic Graphics Frame]"].enable_stroke.set( :to => false )
		@finalDoc.object_styles["[Basic Graphics Frame]"].enable_fill.set( :to  => false )
		@finalDoc.object_styles["[Basic Graphics Frame]"].enable_stroke_and_corner_options.set( :to  => false )

		setEpsExportOptions(:all)

		@idApp.view_preferences.horizontal_measurement_units.set(:to => :millimeters)
		@idApp.view_preferences.vertical_measurement_units.set(:to => :millimeters)

		#voor drukwerk en geregeld door pdf preset
		#@finalDoc.document_preferences.document_bleed_top_offset.set(:to => "3mm")
	end

	#FIXME remove double code
	def createSpreads()	
		getSpreadKeys.each do |spreadKey|
			destPage = @finalDoc.pages.get.length
			pageArr = getPageByIndexAndSide(spreadKey.to_i,'single')

			if pageArr
				copySrcPageItems(pageArr[1]['sourceId'].to_i, destPage, spreadKey)
			end


			#			destPage = @finalDoc.pages.get.length
			pageArr 	= getPageByIndexAndSide(spreadKey.to_i,'left')

			if pageArr
				copySrcPageItems(pageArr[1]['sourceId'].to_i, destPage, spreadKey)
			end

			#			destPage = @finalDoc.pages.get.length
			pageArr = getPageByIndexAndSide(spreadKey.to_i,'right')

			if pageArr
				copySrcPageItems(pageArr[1]['sourceId'].to_i, destPage, spreadKey)
			end
		end
		@finalDoc.delete(@finalDoc.pages[1])
	end

	# o.a. lijst met zichtbare layers opstellen
	def findFields(source, spreadKey)

		@visibleLayers_array = Array.new

		@finalHash['document']['spreads'].each do |spread|
			spread[1]['pages'].each do |page|
				if(page[1]['sourceId'].to_i == source.to_i && spread[1]['index'] == spreadKey)
					if(page[1].key?('layerGroups') && page[1]['layerGroups'].class == Hash)
						page[1]['layerGroups'].each do |group|
							group[1].each do |layer|

								if layer[0][5..-1].to_i > 0
									@visibleLayers_array << layer[0][5..-1]
								end

								if(layer[1].key?('layerChilds') && layer[1]['layerChilds'] != nil)
									layer[1]['layerChilds'].each do |obj|
										replaceFields(obj)
									end
								end
							end
						end
					end
				end
			end
		end
	end

	def replaceFields(obj, stack = false)
		if(obj[0].to_s[0,5] == 'stck_' && stack == false)
			replaceStackFields(obj)
		elsif(obj[0].to_s[0,4] == 'grp_')
			replaceGroupItems(obj, stack)
		elsif(!checkStatic(obj))
			replaceFieldsByType(obj, stack)
		end
	end

	def replaceStackFields(obj)
		used = 0
		if(!obj[1]['stck_content'].nil?)
			obj[1]['stck_content'].each do |stck_obj|
				if(obj[1].key?('p3s_maxuse') && used != obj[1]['p3s_maxuse'])
					if(stck_obj[0].to_s[0,5] != 'stck_')
						replaceFields(stck_obj, true)
						if(stck_obj[0].to_s[0,4] == 'grp_')
							stck_obj[1]['grp_content'].each do |grp_obj|
								grp = @idDoc.page_items[its.id_.eq(grp_obj[1]['objectID'].to_i)]
								if(grp.exists)
									geom  = grp.geometric_bounds.get
									newx  = (obj[1].key?('p3s_marginx')) ? geom[1] + (obj[1]['p3s_marginx'].to_f * used) : geom[1] 
									newy  = (obj[1].key?('p3s_marginy')) ? geom[0] + (obj[1]['p3s_marginy'].to_f * used) : geom[0]
									if(obj[1]['p3s_visible'] != "false" && grp_obj[1]['p3s_visible'] != 'false')
										nwgrp = grp.duplicate()
										nwgrp.move(:to => [newx, newy])
									end
								end
							end
						else
							grp = @idDoc.page_items[its.id_.eq(stck_obj[1]['objectID'].to_i)]
							if(grp.exists)
								geom  = grp.geometric_bounds.get
								newx  = (obj[1].key?('p3s_marginx')) ? geom[1] + (obj[1]['p3s_marginx'].to_f * used) : geom[1] 
								newy  = (obj[1].key?('p3s_marginy')) ? geom[0] + (obj[1]['p3s_marginy'].to_f * used) : geom[0]
								if(obj[1]['p3s_visible'] != "false")
									nwgrp = grp.duplicate()
									nwgrp.move(:to => [newx, newy])
								end
							end
						end
					end
					used += 1
				end
			end
		end
		deleteFirstGroupOrChild(obj[1]['stck_content'])
	end

	def replaceGroupItems(obj, stack)
		if(obj[1].key?('grp_content'))
			obj[1]['grp_content'].each do |grp_obj|
				replaceFields(grp_obj, stack)
			end
		end
	end		

	def replaceFieldsByType(obj, stack)
		if(obj[1].key?('label'))
			l("replacing " + obj[1]['objectID'].to_s + " - " + obj[1]['label'].to_s)
			case obj[1]['label'].to_s[0,obj[1]['label'].index('_')]
				#workaround for pas3-2.1.1-p3ga port
            when 'mergeTextField'
				replaceText(obj, stack)
            when 'mergeText'
				replaceText(obj, stack)
			when 'text'
				replaceText(obj, stack)
			when 'image'
				replaceImage(obj, stack)
			when 'color'
				replaceColor(obj, stack)
			when 'object'
				replaceObject(obj, stack)
			end
		end
	end

	def replaceText(obj, stack)
		item = @idDoc.text_frames[its.id_.eq(obj[1]['objectID'].to_i)]
		if(!obj[1]['content'].nil?)
			item.contents.set(:to => obj[1]['content'].strip)
			item.paragraphs.fill_color.set(:to => item.characters[1].fill_color.get)
		else
			obj[1]['p3s_visible'] = "false"
		end

		##FIXME
		#quick workaround for P3ga Suk NL
		if(obj[1]['label'] == "mergeText_dealername")
			scaleBackText(item)
		end
        
		##FIXME
		#quick workaround for P3ga Suk SE
		if(obj[1]['label'] == "mergeTextField_000_dealername")
			scaleBackText(item)
		end
        
		##FIXME
		#quick workaround for P3ga Suk NL
		if(obj[1]['label'] == "mergeText_dealerAdress")
			breakTextAtComma(item)
		end
        
		##FIXME
		#quick workaround for P3ga Suk SE        
		if(obj[1]['label'] == "mergeTextField_000_dealeraddress")
			breakTextAtComma(item)
		end
        
		if(obj[1]['p3s_overflow'] == "scale")
			scaleBackText(item)
		end

		if(obj[1]['p3s_visible'] == "false" && stack == false)
			item.delete()
		end

		if(obj[1]['p3s_rich'] == "true")
			replaceHTMLTags(obj)
		end
	end

	def replaceImage(obj, stack)
		item 		= @idDoc.rectangles[its.id_.eq(obj[1]['objectID'].to_i)]

		page_width 	= @idDoc.document_preference.page_width.get
		geo 		= item.geometric_bounds.get
		obj_width 	= geo[3].to_f - geo[1].to_f

		if(obj[1].key?("p3s_img_src"))
			item.all_page_items.delete()
			p3s_absolute_img_src = File.join($remoteDummyRootDir,obj[1]['p3s_img_src'])

			if(File.exists?(p3s_absolute_img_src) && File.readable?(p3s_absolute_img_src) && File.file?(p3s_absolute_img_src)) 
				item.frame_fitting_option.fitting_on_empty_frame.set(:to => :proportionally)
				item.place(MacTypes::FileURL.path(p3s_absolute_img_src).hfs_path)
				item.frame_fitting_option.fitting_alignment.set(:to => :bottom_center_anchor)
				if(obj[1]['p3s_overflow'] == "crop")
					item.fit(:given => :fill_proportionally)
				else
					item.fit(:given => :proportionally)
				end
			else
				obj[1]['p3s_visible'] = "false"
			end
		end
		if(obj[1]['p3s_visible'] == "false" && stack == false)
			item.delete()
		end
	end

	def replaceColor(obj, stack)
		colors = obj[1]['p3s_value'].split(',')
		if(colors.length == 4)
			nwColor = @idDoc.make(:new => :color, :with_properties => {:space => :CMYK, :color_value => [colors[0].to_i, colors[1].to_i, colors[2].to_i, colors[3].to_i]})
			@idDoc.rectangles[its.id_.eq(obj[1]['objectID'].to_i)].fill_color.set(:to => nwColor)
		end
		if(obj[1]['p3s_visible'] == "false" && stack == false)
			@idDoc.page_items[its.id_.eq(obj[1]['objectID'].to_i)].delete()
		end
	end

	def replaceObject(obj, stack)
		if(obj[1]['p3s_visible'] == "false" && stack == false)
			@idDoc.page_items[its.id_.eq(obj[1]['objectID'].to_i)].delete()
		end
	end

	def replaceHTMLTags(obj)
		if(obj[1].key?("p3s_rich"))
			obj[1].each do |key, val|
				tag = key.to_s[4..-1]
				if((!tag.nil? && tag != '') && obj[1]['content'].match(/<#{tag}[^>]*>/))
					item 		= @idDoc.text_frames[its.id_.eq(obj[1]['objectID'].to_i)]
					content 	= item.contents.get.to_s
					start 		= content.index(/<#{tag}[^>]*>/)
					ending 		= content.index("</#{tag}>")+tag.length+1
					replace 	= content.to_s[start, ending]
					replacement = replace.to_s[replace.index(">")+1, replace.rindex("<")-4]
				end
			end
		end
	end

	#afbreken op komma
	def breakTextAtComma(obj)
		cnt = ''
		lines = @idDoc.get(obj.lines.object_reference, :result_type => :list)
		if lines.length > 1
			lines.each do |line|
				line = @idDoc.get(line.contents, :result_type => :string)
				line = line.strip
				if line
					if line.rindex(',')
						cnt += line.to_s[0, line.rindex(',')+1] + 10.chr  + line.to_s[(line.rindex(',')+1)..-1]
					else
						cnt += line.to_s
					end
				end
			end
			@idDoc.set(obj.contents, :to => cnt)
		end
	end


	def scaleBackText(obj)
		while @idDoc.get(obj.overflows).to_s == 'true'
			pointS = @idDoc.get(obj.text.point_size)
			par = @idDoc.get(obj.paragraphs.object_reference, :result_type => :list)
			par.each do |para|
				@idDoc.set(para.point_size, :to => pointS[0].to_i-1 )
			end
		end
	end

	# this function deletes all invisible page items so they can not be exported
	def deleteHiddenPageItems(srcPageId)
		pageItems = @idDoc.pages[its.id_.eq(srcPageId)].page_items.get

		pageItems.each do |item|
			parent_layer_id = item.item_layer.get.id_.get.to_s
			if !@visibleLayers_array.include?(parent_layer_id)
				item.delete()
			end
		end
	end

	def copySrcPageItems(srcPageId, destPage, spreadKey)
		findFields(srcPageId, spreadKey)
		deleteHiddenPageItems(srcPageId)

		if(@idDoc.pages[its.id_.eq(srcPageId)].page_items.get.length > 1)
			@idDoc.pages[its.id_.eq(srcPageId)].make(:new => :group, :with_properties =>{:group_items => @idDoc.pages[its.id_.eq(srcPageId)].page_items.get})
		end
		nwlayer = @finalDoc.make(:new => :layer, :with_properties => {:name => 'page' + destPage.to_s})
		pageCopy = @idDoc.pages[its.id_.eq(srcPageId)].duplicate(:to => @finalDoc.pages[destPage])
		pageCopy.page_items.move(:to => nwlayer, :by => [0,0])

		@idDoc.revert()
	end



	def getSpread(key)
		@finalHash['document']['spreads'].each do |spread|
			if(spread[1]['index'] == key)
				return spread
			end
		end
	end

	def getSpreadKeys
		_ret_array = Array.new
		@finalHash['document']['spreads'].each do |spread|
			_ret_array << spread[1]['index']
		end

		return _ret_array.sort
	end

	def getPageByIndexAndSide(index,side)
		@finalHash['document']['spreads'].each do |spread|
			if(spread[1]['index'].to_i == index)
				spread[1]['pages'].each do | page|

					return page if page[1]['side'] == side

				end
			end
		end

		return false
	end

	def checkStatic(obj)
		if(obj[1]['isStatic'] == 'false')
			return false
		else
			return true
		end
	end


	def deleteFirstGroupOrChild(obj)
		if(obj.keys[0].to_s[0,4] == 'grp_')
			obj.values[0]['grp_content'].each do |grp_obj|
				if(@idDoc.page_items[its.id_.eq(grp_obj[1]['objectID'].to_i)].exists)
					@idDoc.page_items[its.id_.eq(grp_obj[1]['objectID'].to_i)].delete()
				end
			end
		else
			if(@idDoc.page_items[its.id_.eq(obj.values[0]['objectID'].to_i)].exists)
				@idDoc.page_items[its.id_.eq(obj.values[0]['objectID'].to_i)].delete()
			end
		end
	end

	def is_mergeTextField(page_item)
		if page_item.label.get.to_s.downcase.index('mergetextfield') != nil
			return true
		else
			return false
		end
	end
end
