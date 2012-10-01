require 'base64'
require 'fileutils'
require 'iconv'

class P3Indesign_import < P3Indesign_library
    
	def initialize(filePath,  relPath,  outputPath, idApp)
        
		super(filePath,  relPath,  outputPath, idApp)
        
		@outputPath	= outputPath
	end
    
	public
    
	def renderPdf (xmlencoded, pdfPreset, outputBaseName, genSWF=false, copyINDD=false)
		@outputBaseName = Base64.decode64(outputBaseName)
		@pdfPreset = Base64.decode64(pdfPreset)
        
		if(not File.exists?(@filePath))
            P3libLogger::log("file path is not reacheable. Is the mount working?",@filePath)
            return false
		end
        
		if(not isPresetAvailable(@pdfPreset))
			P3libLogger::log("preset is not available",@pdfPreset)
			return false
		end
        
		render(xmlencoded, true , genSWF, copyINDD, false)
	end
    
	def renderJpg(xmlencoded, outputBaseName)
		@outputBaseName = Base64.decode64(outputBaseName)
		render(xmlencoded, false, false, false, true)
	end
    
	def render(xmlencoded, genPDF=false, genSWF=false, copyINDD=false, genJPEG=false)
        
		$KCODE = 'UTF-8'
        
		#xml is now double encoded
		xml	= Base64.decode64(xmlencoded)
		xml	= Base64.decode64(xml)
        
		P3libLogger::log("Start rendering output","")
        
		@ic		= Iconv.new('UTF-8//TRANSLIT//IGNORE', 'UTF-8')
		@objID_arr 	= Array.new
		@finalHash 	= Hash.from_xml(xml)
        
		FileUtils.mkdir_p @outputPath
		destbasename = @outputPath+@outputBaseName
        
		#close all docs for a fresh start
		closeAllDocsNoSave
		@indesignSourceDoc = openDoc(@filePath)
		
		#make sure we use the correct reference point
		@idApp.layout_windows[1].transform_reference_point.set(:to => :top_left_anchor)
        
		createindesignTempDestDoc()
        
        if (@finalHash['document']['p3s_rubyinclude'])
            P3libLogger::log("ruby include",@finalHash['document']['p3s_rubyinclude'].to_s)
            P3libLogger::log('Calling script',File.join(File.dirname(@filePath),@finalHash['document']['p3s_rubyinclude'].to_s))
            rubyscript=File.join(File.dirname(@filePath),@finalHash['document']['p3s_rubyinclude'].to_s)
            require(rubyscript)
            
            #            ci.epsToPng(orig, File.dirname(dest)+'/_'+File.basename(dest)+);
            
            
            #als bestand bestaat
            #include en log
        end
        
		
        createSpreads()
		allVisible(@indesignTempDestDoc)
        
		if genPDF
			destpdf	= destbasename+'.pdf'
			exec_exportPDF(@indesignTempDestDoc,destpdf,@pdfPreset)
		end
        
		if genJPEG
			destJPGDir	= @outputPath+'PAS3-Jpeg'
			FileUtils.mkdir(destJPGDir)
			destJPGFilePath	= @outputPath+'PAS3-Jpeg/PAS3.jpg'
			setJpegExportOptions(':all')
			exportJPEG(@indesignTempDestDoc,destJPGFilePath)
		end
        
		if genSWF
			destSwfDir	= @outputPath+'PAS3-Flash'
			destSwfFilePath	= @outputPath+'PAS3-Flash/PAS3-Flash.swf'
			FileUtils.mkdir(destSwfDir)
            
			setSwfOptions()
			exportSwf(@indesignTempDestDoc,destSwfFilePath)
		end
        
		if copyINDD
			packPath=@outputPath+'PAS3-Pack'
			FileUtils.mkdir(packPath)
			packPath=MacTypes::FileURL.path(packPath).hfs_path
            
			destindd	= destbasename+'.tmp.indd'
            
			P3libLogger::log('exporting tmp INDD using path',packPath)
			@nwDoc = @idApp.save(@indesignTempDestDoc, :to => MacTypes::FileURL.path(destindd).hfs_path, :timeout => 0)
			#@nwDoc = @idApp.save(@indesignTempDestDoc, :to => MacTypes::FileURL.path(destpdf).hfs_path.to_s[0..-5]+'tmp.indd', :timeout => 0)
            
			#P3libLogger::log('exporting INDD package using path',packPath)
            
			#FIXME why can't we export to a package?
			#@idApp.package(@indesignTempDestDoc, :to => packPath, :ignore_preflight_errors => :yes, :including_hidden_layers => :yes, :copying_profiles => :no, :creating_report => :no, :copying_fonts => :no, :updating_graphics => :yes, :copying_linked_graphics => :yes, :force_save => :yes, :version_comments => 'Packed by PAS3' ,:timeout => 0)
            
			#FIXME probably fails @newdoc & @indesignTempDestDoc can't both be closed because it's one and the same document
			P3libLogger::log('closing tmp INND file')
			closeDoc(@nwDoc)
		end
        
		P3libLogger::log('closing temperary destination INND file','')
		closeDoc(@indesignTempDestDoc)
		P3libLogger::log('closing source INND file','')
		closeDoc(@indesignSourceDoc)
	end
    
	def setSwfOptions
		if(@idApp.to_s == "app(\"/Applications/Adobe InDesign CS4/Adobe InDesign CS4.app\")")
			@idApp.transparency_preference.blending_space.set(:to => :RGB)
			@idApp.SWF_export_preferences.curve_quality.set(:to => :maximum)
			@idApp.SWF_export_preferences.fit_option.set(:to => :fit800x600)
			@idApp.SWF_export_preferences.generate_HTML.set(:to => true)
			@idApp.SWF_export_preferences.include_hyperlinks.set(:to => false)
			@idApp.SWF_export_preferences.include_interactive_page_curl.set(:to => true)
			@idApp.SWF_export_preferences.include_page_transitions.set(:to => true)
			@idApp.SWF_export_preferences.JPEG_quality_options.set(:to => :maximum)
			@idApp.SWF_export_preferences.page_range.set(:to => :all_pages)
			@idApp.SWF_export_preferences.view_SWF_after_exporting.set(:to => false)
		end
	end
    
	def exportSwf(doc,destSwfFilePath)
		if(@idApp.to_s == "app(\"/Applications/Adobe InDesign CS4/Adobe InDesign CS4.app\")")
			P3libLogger::log('exporting SWF using path',destSwfFilePath)
			@idApp.export(doc, :format => :SWF, :to => MacTypes::FileURL.path(destSwfFilePath).hfs_path, :showing_options => false, :timeout => 0)
            else
			P3libLogger::log("Can't export SWF. SWF export is only available in Indesign versions > CS3","")
		end
	end
    
	# Create the temperary destination document
	def createindesignTempDestDoc
		P3libLogger::log("creating temperaty destination doc",'')
		@indesignTempDestDoc = @idApp.make(:new => :document)
        
		setEpsExportOptions(:all)
		@idApp.transparency_preference.blending_space.set(:to => :CMYK)
		@indesignTempDestDoc.document_preferences.page_width.set(:to => @indesignSourceDoc.document_preferences.page_width.get.to_s+"mm")
		@indesignTempDestDoc.document_preferences.page_height.set(:to => @indesignSourceDoc.document_preferences.page_height.get.to_s+"mm")
        
		@idApp.view_preferences.horizontal_measurement_units.set(:to => :millimeters)
		@idApp.view_preferences.vertical_measurement_units.set(:to => :millimeters)
        
		#TODO MAKE option #2557
		@indesignTempDestDoc.document_preferences.document_bleed_top_offset.set(:to => "3mm")
	end
    
	# Setup the spreads in the destination document
	def createSpreads()
		P3libLogger::log("creating spreads",'')
        
		if(getFirstSpreadPageCount() == '2')
			sections = @indesignTempDestDoc.sections.get
			sections[0].properties__.set(:to => {:continue_numbering => false, :page_start => 2, :page_number_start => 2})
		end
        
		getSpreadKeys.each do |spreadKey|
			P3libLogger::log("creating spreads2",'')
			destPage = @indesignTempDestDoc.pages.get.length
			P3libLogger::log("creating spreads3",'')
			pageArr = getPageByIndexAndSide(spreadKey.to_i,'left')
			P3libLogger::log("creating spreads4",'')
            
			if pageArr
				copySrcPageItems(pageArr[1]['sourceId'].to_i, destPage, spreadKey)
			end
            
			destPage = @indesignTempDestDoc.pages.get.length
			pageArr = getPageByIndexAndSide(spreadKey.to_i,'right')
            
			if pageArr
				copySrcPageItems(pageArr[1]['sourceId'].to_i, destPage, spreadKey)
			end
            
			destPage = @indesignTempDestDoc.pages.get.length
			pageArr = getPageByIndexAndSide(spreadKey.to_i,'single')
            
			if pageArr
				copySrcPageItems(pageArr[1]['sourceId'].to_i, destPage, spreadKey)
			end
            
		end
        
		P3libLogger::log("delete temporary page",'')
		@indesignTempDestDoc.delete(@indesignTempDestDoc.pages[1])
	end
    
	def replaceFields(obj, stack = false)
        P3libLogger::log("starting with item " + obj[0].to_s,"")
		label = (obj[1].key?('label')) ? obj[1]['label'].to_s[0,obj[1]['label'].index('_')] : ''
        
		if((obj[1]['type'].to_s[0,5] == 'stack') && stack == false)
			P3libLogger::log("replacing stack items " + obj[0].to_s)
			replaceStackFields(obj)
            elsif(obj[0].to_s[0,4] == 'grp_')
            P3libLogger::log("replacing group items " + obj[0].to_s)
			replaceGroupItems(obj, stack)
            elsif(label  == 'slot')
			P3libLogger::log("replacing slot items " + obj[0].to_s)
            placeTemplateObjectsInSlotFields(obj,stack)
            elsif(!checkStatic(obj))
            replaceFieldsByType(obj, stack)
        end
    end
    
    def replaceStackFields(obj)
        
        used = 0
        lastElementGeoInfo = Hash.new
        startingGeo = Hash.new
        subdivloopcounter = 0
        subdivnumber = 0
        subdivDoMove = true
        
        
        if(!obj[1]['stck_content'].nil?)
            
            subdivloopcounter = 0
            if(obj[1].key?('p3s_subdivnumber'))
                subdivnumber = obj[1]['p3s_subdivnumber'].to_i
                if(subdivnumber == 1)
                    P3libLogger::log("Disabling subdivision for this stack. subdivnumber = 1 is non sense.",'')
                    subdivnumber = 0
                end
                else
                subdivnumber = 0
            end
            
            sortedStackContent = []
            
            if(obj[1]['reverse_order']== "true")
                obj[1]['stck_content'].reverse_each do |stck_obj|
                    sortedStackContent << stck_obj
                end
                else
                sortedStackContent = obj[1]['stck_content'].sort
            end
            
            sortedStackContent.each do |stck_obj|
                if((obj[1].key?('p3s_maxuse') && used != obj[1]['p3s_maxuse'].to_i) || !obj[1].key?('p3s_maxuse'))
                    
                    if(stck_obj[0].to_s[0,5] != 'stck_')
                        replaceFields(stck_obj, true)
                        
                        if(stck_obj[0].to_s[0,4] == 'grp_')
                            items_arr 			= Array.new
                            growElementArray 	= Array.new
                            stackRowArray 		= Array.new
                            growElement	     	= false
                            growMarginX			= ''
                            
                            stck_obj[1]['grp_content'].each do |grp_obj|
                                if(obj[1]['ret_p3s_visible'] != "false" && grp_obj[1]['ret_p3s_visible'] != 'false')
                                    new_item = @indesignSourceDoc.page_items[its.id_.eq(getCorrectObjId(grp_obj[1]['objectID']))].duplicate()
                                    items_arr.push(new_item)
                                    if(grp_obj[1].key?('p3s_growsimilar') && grp_obj[1]['p3s_growsimilar'].strip == 'true' )
                                        growElement = true
                                        growElementArray.push(new_item)
                                        if(grp_obj[1].key?('p3s_growmarginx'))
                                            growMarginX = grp_obj[1]['p3s_growmarginx']
                                        end
                                        else
                                        stackRowArray.push(new_item)
                                    end
                                end
                            end
                            
                            # just implemented for height now
                            if(growElement && stackRowArray.count > 0)
                                
                                stackGroup = groupItems(stackRowArray)
                                
                                groupGeom 	= elementGeoInfo(stackGroup)
                                
                                growElementArray.each do |item|
                                    itemGeom = elementGeoInfo(item)
                                    #TODO fix with growmarginx
                                    if(growMarginX != nil)
                                        item.geometric_bounds.set([itemGeom['topPos'], itemGeom['leftPos'], groupGeom['bottomPos']+growMarginX.to_f, itemGeom['rightPos']])
                                        else
                                        item.geometric_bounds.set([itemGeom['topPos'], itemGeom['leftPos'], groupGeom['bottomPos'], itemGeom['rightPos']])
                                    end
                                end
                                
                                unGroup(stackGroup);
                            end
                            
                            newGroup = groupItems(items_arr)
                            
                            else
                            if(stck_obj[1]['ret_p3s_visible'] != "false" || stck_obj[1]['p3s_visible'] != "false")
                                newGroup = @indesignSourceDoc.page_items[its.id_.eq(getCorrectObjId(stck_obj[1]['objectID']))].duplicate()
                            end
                        end
                        
                        
                        if(newGroup != nil)
                            
                            if (used == 0)
                                startingGeo = elementGeoInfo(newGroup)
                                lastElementGeoInfo = startingGeo
                            end
                            
                            #are we using subdivisions
                            if(subdivnumber > 0)
                                
                                subdivloopcounter += 1
                                
                                #Start a new subdivision
                                if(subdivloopcounter == (subdivnumber+1))
                                    subdivDoMove = false
                                    
                                    subdivloopcounter = 0
                                    
                                    if(obj[1]['p3s_subdivmargintypey'] 	!= "relative")
                                        startingGeo['topPos']		+= obj[1]['p3s_subdivmarginy'].to_f
                                        startingGeo['bottomPos']	+= obj[1]['p3s_subdivmarginy'].to_f + startingGeo['height']
                                        else
                                        startingGeo['topPos']		+= startingGeo['height'] + obj[1]['p3s_subdivmarginy'].to_f
                                        startingGeo['bottomPos']	+= startingGeo['height'] + obj[1]['p3s_subdivmarginy'].to_f + startingGeo['height']
                                    end
                                    
                                    if(obj[1]['p3s_subdivmargintypex'] 	!= "relative")
                                        startingGeo['leftPos']	+= obj[1]['p3s_subdivmarginx'].to_f
                                        startingGeo['rightPos']	+= obj[1]['p3s_subdivmarginx'].to_f + startingGeo['width']
                                        else
                                        startingGeo['leftPos']	+= startingGeo['width'] + obj[1]['p3s_subdivmarginx'].to_f
                                        startingGeo['rightPos']	+= startingGeo['width'] + obj[1]['p3s_subdivmarginx'].to_f + startingGeo['width']
                                    end
                                    
                                    lastElementGeoInfo = moveToNewGeoPosition("absolute", "absolute", 0.0, 0.0, startingGeo, newGroup)
                                    
                                    else
                                    subdivDoMove = true
                                end
                                
                            end
                            
                            if(used > 0 && subdivDoMove)
                                #de opz'nplekblijfcode
                                #TODO kan niet goed werken geen p3s prefix
                                if(obj[1]['p3s_margintypex'] != "relative" && obj[1]['p3s_marginx'].to_f == 0)
                                    lastElementGeoInfo['leftPos'] = startingGeo['leftPos']
                                    elsif(obj[1]['p3s_margintypexy'] != "relative" && obj[1]['p3s_marginy'].to_f == 0)
                                    lastElementGeoInfo['topPos'] = startingGeo['topPos']
                                end
                                
                                lastElementGeoInfo = moveToNewGeoPosition(obj[1]['p3s_margintypex'], obj[1]['p3s_margintypey'], obj[1]['p3s_marginx'], obj[1]['p3s_marginy'], lastElementGeoInfo, newGroup,true)
                            end
                            
                            used += 1
                        end
                    end
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
    
    def placeTemplateObjectsInSlotFields(obj,stack)
        slotElement= @indesignSourceDoc.page_items[its.id_.eq(obj[1]['objectID'].to_i)]
        slotElementCoords = elementGeoInfo(slotElement)
        
        lastElementGeoInfo = slotElementCoords
        lastElementGeoInfo['rightPos'] = slotElementCoords['leftPos']
        lastElementGeoInfo['bottomPos'] = slotElementCoords['topPos']
        
        P3libLogger::log("placing Template Objects In Slot Fields ",'')
        
        elIdx=0
        
        if(obj[1].key?('ret_p3s_elements'))
            obj[1]['ret_p3s_elements'].sort.each do |elementObj|
                elIdx+=1
                templateName = nil
                
                if(elementObj[1].key?('p3s_template'))
                    templateName = elementObj[1]['p3s_template'].to_s
                    P3libLogger::log("Identify dynamic template ",templateName)
                    else
                    elementObj[1]['childs'].each do |elementObjChild|
                        if(!elementObjChild[1]['memberoftemplate'].nil? )
                            templateName = elementObjChild[1]['memberoftemplate'].to_s
                            P3libLogger::log("Identify Template ",templateName)
                        end
                        break
                    end
                end
                
                if(!templateName.nil?)
                    
                    P3libLogger::log("Access Template ",templateName)
                    tplLayer 	= findLayer(templateName)
                    newLayer 	= tplLayer.duplicate()
                    layerID		= newLayer.id_.get.to_s
                    tmpName 	= tplLayer.name.get.to_s+layerID
                    P3libLogger::log('creating new layer: ' + tmpName)
                    newLayer.name.set(:to=> tmpName)
                    trackObjectIds(tplLayer, newLayer)
                    
                    P3libLogger::log("Merge Template With Element ",'')
                    growElement 		= false
                    growElementArray	= Array.new
                    
                    elementObj[1]['childs'].each do |elementObjChild|
                        if(elementObjChild[1].key?('p3s_growsimilar') && elementObjChild[1]['p3s_growsimilar'].strip == 'true' )
                            growElement = true
                            growElementArray  << elementObjChild
                        end
                    end
                    
                    elementObj[1]['childs'].each do |elementObjChild|
                        P3libLogger::log('replace slot field')
                        replaceFields(elementObjChild, stack)
                    end
                    
                    #TODO clean up and move to new function
                    if(growElement)
                        growElementArray.each do |growElement|
                            grpArray 	= tplLayer.page_items.get
                            grpIndex	= 0
                            grpExists	= false
                            
                            grpArray.each do  |grpObj|
                                if(grpObj.to_s.index(growElement[1]['objectID']) != nil)
                                    grpArray.slice!(grpIndex)
                                end
                                grpIndex += 1
                            end
                            
                            newGroup 	= groupItems(grpArray)
                            groupGeom 	= newGroup.geometric_bounds.get
                            
                            oldHeight	= groupGeom[2] - groupGeom[0]
                            oldWidth 	= groupGeom[3] - groupGeom[1]
                            unGroup(newGroup)
                            
                            grpArray 	= newLayer.page_items.get
                            grpIndex	= 0
                            grpArray.each do  |grpObj|
                                if(grpObj.to_s.index(getCorrectObjId(growElement[1]['objectID']).to_s) != nil)
                                    grpArray.slice!(grpIndex)
                                    grpExists = true
                                end
                                grpIndex += 1
                            end
                            
                            if(grpExists)
                                newGroup	= groupItems(grpArray)
                                groupGeom 	= newGroup.geometric_bounds.get
                                
                                diffHeight 	= (groupGeom[2] - groupGeom[0]) - oldHeight
                                diffWidth 	= (groupGeom[3] - groupGeom[1]) - oldWidth
                                unGroup(newGroup)
                                
                                item 		= newLayer.page_items[its.id_.eq(getCorrectObjId(growElement[1]['objectID']))]
                                itemGeom 	= item.geometric_bounds.get
                                
                                growX		=  (growElement[1].key?('p3s_growmarginx')) ? growElement[1]['p3s_growmarginx'].to_f : 0
                                growY		=  (growElement[1].key?('p3s_growmarginy')) ? growElement[1]['p3s_growmarginy'].to_f : 0
                                
                                item.geometric_bounds.set([itemGeom[0], itemGeom[1], itemGeom[2] + diffHeight + growY, itemGeom[3] + diffWidth + growX])
                                item.geometric_bounds.get
                            end
                        end
                    end
                    
                    
                    newGroup = groupItems(newLayer.page_items.get)
                    newGroup.item_layer.set(slotElement.item_layer)
                    newGroup.move(:to => slotElement.parent.get )
                    
                    if(elIdx == 1)
                        lastElementGeoInfo = moveToNewGeoPosition("absolute", "absolute", 0, 0, lastElementGeoInfo, newGroup)
                        else
                        lastElementGeoInfo = moveToNewGeoPosition(obj[1]['p3s_margintypex'], obj[1]['p3s_margintypey'], obj[1]['p3s_marginx'], obj[1]['p3s_marginy'], lastElementGeoInfo, newGroup)
                    end
                    
                    newLayer.delete()
                end
            end
            slotElement.delete()
        end
    end
    
    def replaceFieldsByType(obj, stack)
        if(obj[1].key?('label'))
            P3libLogger::log("start replacing field " + obj[1]['objectID'].to_s + " - " + obj[1]['label'].to_s)
            case obj[1]['label'].to_s[0,obj[1]['label'].index('_')]
                when 'text'
                replaceText(obj, stack)
                when 'image'
                replaceImage(obj, stack)
                when 'color'
                replaceColor(obj, stack)
                when 'object'
                replaceObject(obj, stack)
            end
            P3libLogger::log("finished processing field " + obj[1]['objectID'].to_s + " - " + obj[1]['label'].to_s)
        end
    end
    
    def replaceText(obj, stack)
        item = @indesignSourceDoc.text_frames[its.id_.eq(getCorrectObjId(obj[1]['objectID']))]
        
        if(!obj[1]['content'].nil? && obj[1]['content'].strip != 'false')
            if(obj[1].key?('h') && obj[1].key?('w'))
                thisGeo = elementGeoInfo(item)
                
                h = obj[1]['h'].to_f/100 * 25.4
                w = obj[1]['w'].to_f/100 * 25.4
                item.geometric_bounds.set([thisGeo['topPos'], thisGeo['leftPos'], thisGeo['topPos'] + h, thisGeo['leftPos'] + w])
            end
            
            story =	item.parent_story.get
            story.contents.set(:to => @ic.iconv(obj[1]['content'].strip + ' ')[0..-2])
            story.contents.set(:to => obj[1]['content'].strip)
            
            if(obj[1]['p3s_rich'] == "true")
                objReplaceHTMLTags(obj)
            end
            
            if(obj[1]['p3s_autobalance'] == "true")
                story.paragraphs.balance_ragged_lines.set(:to => true)
            end
            
            if(obj[1]['p3s_overflow'] == "scale")
                objScaleBackText(item)
            end
            
            if(obj[1]['p3s_autosize'] == "true")
                item.fit(:given => :frame_to_content)
            end
            
            
            if(obj[1].key?('ret_p3s_textfill'))
                objSetTextFill(obj)
            end
            
            if(obj[1]['p3s_createoutlines'] == "true")
                P3libLogger::log('Creating outlines. This could not work inside a stack.','')
                item.create_outlines
            end
            
            else
            obj[1]['ret_p3s_visible'] = "false"
        end
        
        if(obj[1]['ret_p3s_visible'] == "false" && stack == false)
            item.delete()
        end
    end
    
    def replaceImage(obj, stack)
        item 		= @indesignSourceDoc.rectangles[its.id_.eq(getCorrectObjId(obj[1]['objectID']))]
        
        if(obj[1].key?("p3s_img_src"))
            item.all_page_items.delete()
            p3s_absolute_img_src = File.join($remoteDummyRootDir,obj[1]['p3s_img_src'])
            if(File.exists?(p3s_absolute_img_src) && File.readable?(p3s_absolute_img_src) && File.file?(p3s_absolute_img_src))
                item.frame_fitting_option.fitting_on_empty_frame.set(:to => :proportionally)
                
                if(obj[1].key?("p3s_align"))
                    if(obj[1]['p3s_align'].to_s != "")
                        # seems not to work properly
                        item.frame_fitting_option.fitting_alignment.set(:to => eval(':'+obj[1]['p3s_align'].to_s+'_anchor'))
                    end
                    else
                    item.frame_fitting_option.fitting_alignment.set(:to => :top_left_anchor)
                end
                
                #inDesign CS6 seems to work with regular paths instead of hfs
                begin
                    P3libLogger::log("placing item normal", MacTypes::FileURL.path(p3s_absolute_img_src).to_s)
                    item.place(MacTypes::FileURL.path(p3s_absolute_img_src))
                    rescue
                    begin
                        P3libLogger::log("placing item hfs", MacTypes::FileURL.path(p3s_absolute_img_src).hfs_path.to_s)
                        item.place(MacTypes::FileURL.path(p3s_absolute_img_src).hfs_path)
                        rescue
                        P3libLogger::log("unable to place item", "")
                    end
                end
                
                if(obj[1].key?("p3s_overflow"))
                    if(obj[1]['p3s_overflow'] == "crop")
                        item.fit(:given => :fill_proportionally)
                        else
                        item.fit(:given => :proportionally)
                    end
                    else
                    if(obj[1].key?("p3s_autosize"))
                        if(obj[1]['p3s_autosize'].to_s == "true")
                            item.all_graphics.absolute_horizontal_scale.set(:to => 100)
                            item.all_graphics.absolute_vertical_scale.set(:to => 100)
                            else
                            item.fit(:given => :proportionally)
                        end
                        else
                        item.fit(:given => :proportionally)
                    end
                end
                
                #hier stond ie
                
                if(obj[1].key?("p3s_autosize"))
                    if(obj[1]['p3s_autosize'].to_s == "true")
                        item.fit(:given => :frame_to_content)
                    end
                end
                
                if(obj[1].key?("ret_p3s_fill"))
                    objSetCMYKFill(obj,obj[1]['ret_p3s_fill'])
                    elsif(obj[1].key?("p3s_fill"))
                    if(obj[1]['p3s_fill'].to_s[0,5] == 'RUBY:')
                        #eval_custom_ruby(obj[1]['p3s_fill'].to_s)
                        newcolor=eval_custom_ruby(obj[1]['p3s_fill'].to_s)
                        objSetCMYKFill(obj,newcolor)
                    end
                end
                
                else
                obj[1]['ret_p3s_visible'] = "false"
            end
            elsif(obj[1].key?("ret_p3s_fill"))
            objSetCMYKFill(obj,obj[1]['ret_p3s_fill'])
            elsif(obj[1].key?("p3s_fill"))
            if(obj[1]['p3s_fill'].to_s[0,5] == 'RUBY:')
                newcolor=eval_custom_ruby(obj[1]['p3s_fill'].to_s)
                objSetCMYKFill(obj,newcolor)
            end
            else
            obj[1]['ret_p3s_visible'] = "false"
        end
        
        if(obj[1]['ret_p3s_visible'] == "false" && stack == false)
            item.delete()
        end
    end
    
    def eval_custom_ruby(str2call)
        #P3libLogger::log('Calling script',obj[1]['p3s_fill'].to_s)
        str2call = str2call.delete('\\')
        
        #       P3libLogger::log('Calling script',str2call)
        P3libLogger::log('Calling script',str2call[5..-1])
        
        str2call = str2call[5..-1]
        
        #str2call = obj[1]['p3s_fill'].to_s.delete('\\')
        #str2call = "Ravasprijslijst::rijkleur('50,100,50,100','100,50,100,50')"
        #str2call = "Time.now"
        
        return eval(str2call)
        
        
        #P3libLogger::log('Calling script',str2call)
        #	eval(str2call)
        #P3libLogger::log('Calling scr2ipt',@filePath)
        #	eval(str2call)
    end
    
    
    def replaceColor(obj, stack)
        colors = obj[1]['p3s_value'].split(',')
        if(colors.length == 4)
            nwColor = @indesignSourceDoc.make(:new => :color, :with_properties => {:space => :CMYK, :color_value => [colors[0].to_i, colors[1].to_i, colors[2].to_i, colors[3].to_i]})
            @indesignSourceDoc.rectangles[its.id_.eq(getCorrectObjId(obj[1]['objectID']))].fill_color.set(:to => nwColor)
        end
        if(obj[1]['ret_p3s_visible'] == "false" && stack == false)
            @indesignSourceDoc.page_items[its.id_.eq(getCorrectObjId(obj[1]['objectID']))].delete()
        end
    end
    
    def replaceObject(obj, stack)
        #why is this method renamed to replaceObject
        if(obj[1]['ret_p3s_visible'] == "false" && stack == false)
            @indesignSourceDoc.page_items[its.id_.eq(getCorrectObjId(obj[1]['objectID']))].delete()
        end
    end
    
    def objReplaceHTMLTags(obj)
        P3libLogger::log("objReplaceHTMLTags " + (getCorrectObjId(obj[1]['objectID']).to_s) + " - " + obj[1]['label'].to_s)
        
        #TODO: Add basic HTML translation (bold, italic, underline, ect)
        if(obj[1].key?("p3s_rich"))
            item 		= @indesignSourceDoc.text_frames[its.id_.eq(getCorrectObjId(obj[1]['objectID']))]
            story 		=	item.parent_story.get
            content 	= story.contents.get.to_s
            tag			= 'br'
            
            while(content.match(/<#{tag}[^>]*>/))
                insertionPoint 	= content.index(/<#{tag}[^>]*>/)
                insertionEnd	= content.index('>', insertionPoint)+1
                content 		= content[0, insertionPoint] + content[insertionEnd, content.length].strip
                
                story.contents.set(:to => content)
                story.insertion_points[insertionPoint+1].contents.set(:to => 0x53466C62)
            end
            
            fontStyles	= getAvailableFontStyles(story)
            taglist 	= ['b', 'strong', 'i', 'em', 'u']
            
            taglist.each do |tag|
                content	= story.contents.get.to_s
                if((!tag.nil? && tag != '') && content.match(/<#{tag}[^>]*>/))
                    while(content.match(/<#{tag}[^>]*>/))
                        content		 	= story.contents.get.to_s
                        insertionPoint 	= content.index(/<#{tag}[^>]*>/)
                        insertionEnd 	= content.index("</#{tag}>")+tag.length+1
                        
                        tempString 		= content.to_s[insertionPoint+1, insertionEnd-1]
                        replacement		= tempString.to_s[tempString.index('>')+1, tempString.index('<')-2]
                        content 		= content[0, insertionPoint] + replacement + content[insertionEnd+2, content.length]
                        
                        story.contents.set(:to => content)
                        
                        # finish support for Italic & bold later, probable double byte problem
=begin
                         if(tag == 'b' || tag == 'strong')
                         if(fontStyles.index('Bold') > 0)
                         #		story.characters[insertionPoint, insertionPoint + replacement.length].font_style.set("Bold")
                         else
                         p 'font doesn\'t contain a bold font style, add method to force bold'
                         end
                         elsif(tag == 'i' || tag == 'em')
                         if(fontStyles.index('Italic') > 0)
                         p 'Italic exists'
                         else
                         p 'Italic doesn\'t exist'
                         end
                         elsif(tag == 'u')
                         end
=end
                    end
                end
            end
            
            #what happens here?
            obj[1].each do |key, val|
                tag = key.to_s[4..-1]
                
                if((!tag.nil? && tag != '') && obj[1]['content'].match(/<#{tag}[^>]*>/))
                    content 	= story.contents.get.to_s
                    start 		= content.index(/<#{tag}[^>]*>/)
                    ending 		= content.index("</#{tag}>")+tag.length+1
                    replace 	= content.to_s[start, ending]
                    replacement = replace.to_s[replace.index(">")+1, replace.rindex("<")-4]
                end
            end
        end
    end
    
    def objScaleBackText(obj)
        P3libLogger::log("objScaleBackText ")
        while @indesignSourceDoc.get(obj.overflows).to_s == 'true'
            pointS = @indesignSourceDoc.get(obj.text.point_size)
            par = @indesignSourceDoc.get(obj.paragraphs.object_reference, :result_type => :list)
            par.each do |para|
                @indesignSourceDoc.set(para.point_size, :to => pointS[0].to_i-1 )
            end
        end
    end
    
    def objSetTextFill(obj)
        item = @indesignSourceDoc.text_frames[its.id_.eq(getCorrectObjId(obj[1]['objectID']))]
        story =	item.parent_story.get
        colors = obj[1]['ret_p3s_textfill'].split(',')
        P3libLogger::log("objSetTextFill " + getCorrectObjId(obj[1]['objectID']).to_s + " - " + obj[1]['label'].to_s)
        if(colors.length == 4)
            nwColor = @indesignSourceDoc.make(:new => :color, :with_properties => {:space => :CMYK, :color_value => [colors[0].to_i, colors[1].to_i, colors[2].to_i, colors[3].to_i]})
            story.paragraphs.fill_color.set(:to => nwColor)
        end
    end
    
    def objSetCMYKFill(obj,colorstring)
        #Couldn;t this be done with the replaceColor function? TODO: Somehow merge both functions
        P3libLogger::log("objSetCMYKFill " + getCorrectObjId(obj[1]['objectID']).to_s + " - " + obj[1]['label'].to_s)
        colors = colorstring.split(',')
        if(colors.length == 4)
            nwColor = @indesignSourceDoc.make(:new => :color, :with_properties => {:space => :CMYK, :color_value => [colors[0].to_i, colors[1].to_i, colors[2].to_i, colors[3].to_i]})
            @indesignSourceDoc.rectangles[its.id_.eq(getCorrectObjId(obj[1]['objectID']))].fill_color.set(:to => nwColor)
        end
    end
    
    def trackObjectIds(srcLayer, destLayer)
        srcLayer.page_items.get.each do |item|
            if(item.label.get != nil)
                @objID_arr[item.id_.get] = destLayer.page_items[its.label.eq(item.label.get)].id_.get
            end
        end
    end
    
    def copySrcPageItems(srcPageId, destPage, spreadKey)
        
        P3libLogger::log("copy page items",'')
        findFields(srcPageId, spreadKey)
        
        P3libLogger::log("remove unwanted layers",'')
        removeUnwantedLayers()
        
        P3libLogger::log("group all page items before copy to new document",'')
        if(@indesignSourceDoc.pages[its.id_.eq(srcPageId)].page_items.get.length > 1)
            @indesignSourceDoc.pages[its.id_.eq(srcPageId)].make(:new => :group, :with_properties =>{:group_items => @indesignSourceDoc.pages[its.id_.eq(srcPageId)].page_items.get})
        end
        
        P3libLogger::log("create destination layer",'')
        nwlayer = @indesignTempDestDoc.make(:new => :layer, :with_properties => {:name => 'page' + destPage.to_s})
        
        P3libLogger::log("copy source page with all items to destination document",'')
        
        pageCopy = @indesignSourceDoc.pages[its.id_.eq(srcPageId)].duplicate(:to => @indesignTempDestDoc.pages[destPage])
        pageCopy.page_items.move(:to => nwlayer)
        
        P3libLogger::log("revert all source document changes",'')
        @indesignSourceDoc.revert()
    end
    
    def findFields(source, spreadKey)
        @finalHash['document']['spreads'].each do |spread|
            spread[1]['pages'].each do |page|
                if(page[1]['sourceId'].to_i == source.to_i && spread[1]['index'] == spreadKey)
                    if(page[1].key?('layerGroups') && page[1]['layerGroups'].class == Hash)
                        page[1]['layerGroups'].each do |group|
                            group[1].each do |layer|
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
    
    def findLayer(subname)
        @indesignSourceDoc.layers.get.each do |layer|
            layerName = layer.name.get.to_s.downcase
            if(layerName[3, layerName.length].downcase == subname) then
                return layer
            end
        end
    end
    
    def removeUnwantedLayers
        @indesignSourceDoc.layers.get.each do |layer|
            layerName = layer.name.get.to_s.downcase
            if(layerName[0, 2].downcase == 'tp' || layerName[0, 2].downcase == 'xx') then
                layer.delete()
            end
        end
    end
    
    def getCorrectObjId(_id_)
        return (@objID_arr[_id_.to_i] != nil) ? @objID_arr[_id_.to_i] : _id_.to_i
    end
    
    def getSpread(key)
        @finalHash['document']['spreads'].each do |spread|
            if(spread[1]['index'] == key)
                return spread
            end
        end
    end
    
    def getAvailableFontStyles(content)
        fontStyles	= Array.new
        applFont	= content.characters[1].applied_font.get
        fontFam		= applFont.font_family.get
        allFonts 	= @idApp.fonts.get
        
        allFonts.each do |font|
            if(font.to_s.include? fontFam.to_s)
                fontStyles.push(font.font_style_name.get)
            end
        end
        return fontStyles
    end
    
    def groupItems(items)
        if(items.length > 1)
            begin
                # TODO check if parent IS page
                group = @indesignSourceDoc.pages[its.id_.eq(items[0].parent.id_.get)].make(:new => :group, :with_properties =>{:group_items => items})
                return group
                rescue  Exception => e
                puts e
                return nil
            end
            else
            return items[0]
        end
    end
    
    def unGroup(group)
        if(group.class_.get == :group)
            @indesignSourceDoc.ungroup(group)
        end
    end
    
    def getSpreadKeys
        _ret_array = Array.new
        @finalHash['document']['spreads'].each do |spread|
            _ret_array << spread[1]['index']
        end
        
        return _ret_array.sort
    end
    
    def getFirstSpreadPageCount()
        @finalHash['document']['spreads'].each do |spread|
            if(spread[1]['index'] == '1')
                return spread[1]['page_count']
            end
        end
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
    
    def getNewGeoPos(positioning, margin, lastGeom, coord1, coord2,objectGeom,stackEl=false)
        if(positioning.to_s.downcase == 'relative')
            if(margin != nil && margin != '')
                return lastGeom[coord1].to_f + margin.to_f
                else
                return lastGeom[coord1]
            end
            else
            
            ret = nil
            
            #if stackEl ann absolute 0 then return its own x as new x (implicating no movement)
            if(margin.to_f == 0 && stackEl)
                ret = objectGeom[coord2].to_f
                elsif(margin != nil && margin != '' && margin.to_f != 0)
                ret = lastGeom[coord2].to_f + (margin.to_f)
                else
                ret = lastGeom[coord2].to_f
            end
            return ret
        end
    end
    
    def moveToNewGeoPosition(positioningX, positioningY, marginx, marginy, lastGeom, object,stackEl=false)
        
        objectGeom =elementGeoInfo(object)
        
        newx = getNewGeoPos(positioningX, marginx, lastGeom, 'rightPos', 'leftPos',objectGeom,stackEl)
        newy = getNewGeoPos(positioningY, marginy, lastGeom, 'bottomPos', 'topPos',objectGeom,stackEl)
        
        
        object.move(:to => [newx,newy])
        
        
        return elementGeoInfo(object)
    end
    
    def elementGeoInfo(pageitem)
        
        if(pageitem)
            elementBounds = pageitem.geometric_bounds.get
            
            elementCoordinates 				= Hash.new
            elementCoordinates['topPos']	= elementBounds[0]
            elementCoordinates['leftPos']	= elementBounds[1]
            elementCoordinates['bottomPos']	= elementBounds[2]
            elementCoordinates['rightPos']	= elementBounds[3]
            elementCoordinates['height']	= elementBounds[2] - elementBounds[0]
            elementCoordinates['width']		= elementBounds[3] - elementBounds[1]
            
            return elementCoordinates
            else
            P3libLogger::log("ERROR: ","no object to get geoinfo from")
        end
        
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
                if(@indesignSourceDoc.page_items[its.id_.eq(getCorrectObjId(grp_obj[1]['objectID']))].exists)
                    @indesignSourceDoc.page_items[its.id_.eq(getCorrectObjId(grp_obj[1]['objectID']))].delete()
                end
            end
            else
            if(@indesignSourceDoc.page_items[its.id_.eq(getCorrectObjId(obj.values[0]['objectID']))].exists)
                @indesignSourceDoc.page_items[its.id_.eq(getCorrectObjId(obj.values[0]['objectID']))].delete()
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
