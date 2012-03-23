class P3Indesignfranchise_library
	
	include Appscript

	def initialize(filePath,  relPath,  outputPath, idApp)
		@filePath		= filePath
		@relPath		= relPath
		@outputPath		= outputPath
		@idApp			= idApp

		log('Using file', @filePath)
		log('Using outputPath', @outputPath)
		log('Using relPath', @relPath)
		log('Using Indesign Version', @idApp.to_s)
	end

	public
	def setDryRun
		@dryrun	= true
	end

	def closeAllDocsNoSave

		@idApp.documents.get.each do |doc|
			doc.close(:saving => :no)
			log("Closing all Indesign open documents:", '') 
		end
	end

	private

	def helper_newtempname(len)
		chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
		newpass = ""
		1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
		return newpass
	end


	def log(key,val, type = 'info')
		(class << P3Indesignfranchise_logger; P3Indesignfranchise_logger; end).log(key, val, type)
	end

	def l(key)
		log(key,'')
	end

	def openDoc(doc)
		ret_doc	= @idApp.open(MacTypes::FileURL.path(doc).hfs_path)
		log("Opening Indesign document:", doc) 
		
		unlock(ret_doc)
		breakGroups(ret_doc)
		alterDisplaySettings
		return ret_doc
	end

	def closeDoc(doc)
		doc.close(:saving => :no)
		log("Closing Indesign document:", @filePath) 
	end

	def alterDisplaySettings
		@idApp.script_preferences.user_interaction_level.set(:never_interact)
		@idApp.display_performance_preference.ignore_local_settings.set(:to => true)
		@idApp.display_performance_preference.default_display_settings.set(:to => :optimized)
	end

	def unlock(doc)
		doc.layers.get.each do |layer|
			@idApp.set(layer.visible, :to => true)
			@idApp.set(layer.locked, :to => false)
			@idApp.set(layer.visible, :to => false)
		end
	end

	def allVisible(doc)
		doc.layers.get.each do |layer|
			@idApp.set(layer.visible, :to => true)
		end
	end

	def breakGroups(doc)
		groups = doc.groups.get

		groups.each do |group|
			group.ungroup
		end

		if (doc.groups.get.length > 0) then breakGroups(doc) end	
	end

	def setEpsExportOptions(page)
		@idApp.EPS_export_preferences.page_range.set(:to => page.to_s)
		@idApp.EPS_export_preferences.omit_EPS.set(:to => false)
		@idApp.EPS_export_preferences.bleed_outside.set(:to => 0.000000)
		@idApp.EPS_export_preferences.bleed_bottom.set(:to => 0.000000)
		@idApp.EPS_export_preferences.bleed_inside.set(:to => 0.000000)
		@idApp.EPS_export_preferences.PostScript_level.set(:to => :level_2)
		@idApp.EPS_export_preferences.ignore_spread_overrides.set(:to => false)
		@idApp.EPS_export_preferences.omit_PDF.set(:to => false)
		@idApp.EPS_export_preferences.data_format.set(:to => :binary)
		#@idApp.EPS_export_preferences.data_format.set(:to => :ASCII)
		@idApp.EPS_export_preferences.image_data.set(:to => :all_image_data)
		@idApp.EPS_export_preferences.EPS_color.set(:to => :RGB)
		@idApp.EPS_export_preferences.OPI_image_replacement.set(:to => false)
		@idApp.EPS_export_preferences.omit_bitmaps.set(:to => false)
		@idApp.EPS_export_preferences.EPS_spreads.set(:to => false)
		@idApp.EPS_export_preferences.preview.set(:to => :none)
		@idApp.EPS_export_preferences.applied_flattener_preset.set(:to => "[Low Resolution]")
		#@idApp.EPS_export_preferences.font_embedding.set(:to => :subset)
		@idApp.EPS_export_preferences.font_embedding.set(:to => :complete)
	    @idApp.EPS_export_preferences.image_data.set(:to => :proxy_image_data)
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


	def helperInDesignSideToP3Side(side)
		return side.to_s[0,side.to_s.index('_')]
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

#			if(lastLayer == layerId)
				exportLayer(layer, spread_nr, page_nr)
#			end

#			if(lastLayer == layerId || layerId.downcase == 'xx') 
#				@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].visible, :to => false)
#			else
#				@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].visible, :to => true)
#			end

			lastLayer = layerId

			if(layerGroups.keys.to_s.index('group' + layerId) == nil) then layerGroups[eval(':group' + layerId)] = Hash.new end
			layerGroups[eval(':group' + layerId)][eval(':layer'+layer[:layerID].to_s)] = layer			
		end

		#deze loop is voor de page preview
		layers.each do |layer|
			layerId = layer[:name].to_s[0, 2]

#			if(lastLayer == layerId)
#				exportLayer(layer, spread_nr, page_nr)
#			end

			if(lastLayer == layerId || layerId.downcase == 'xx') 
				@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].visible, :to => false)
			else
				@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].visible, :to => true)
			end

			lastLayer = layerId

#			if(layerGroups.keys.to_s.index('group' + layerId) == nil) then layerGroups[eval(':group' + layerId)] = Hash.new end
#			layerGroups[eval(':group' + layerId)][eval(':layer'+layer[:layerID].to_s)] = layer			
		end

		# add a new layer so there's always something to export
		nwLyr = @idDoc.make(:new => :layer)
		nwObj = @idDoc.pages[its.id_.eq(page)].make(:new => :text_frame)
		nwObj.geometric_bounds.set(['6p', '6p', '18p', '18p'])
		nwObj.move(:to => [5,5])
		nwObj.contents.set(".")
		nwObj.characters.fill_color.set(:to => "Paper")
		nwObj.characters.applied_font.set(:to => "Verdana")
		nwObj.characters.font_style.set(:to => "Bold")
		nwObj.characters.point_size.set(:to => 18)

		page_base_name = @outputPath+'page_'+spread_nr+'_'+page_nr
		pixWidth	= getDimensionInPixels(getDimensionInPixels(@idDoc.document_preferences.page_width.get))
		pixHeight	= getDimensionInPixels(getDimensionInPixels(@idDoc.document_preferences.page_height.get))

		#TODO replace with exec_exportPNG
		exportEPS(@idDoc, page_base_name+'.eps', page_base_name+'.png', pixWidth, pixHeight)
		#exec_exportPNG(@idDoc, page_base_name+'.png')

		# and delete it because there's no further use
		nwObj.delete()
		nwLyr.delete()

		return layerGroups
	end


	##
	# count layers in group by layergroup id, e.g. "03"
	#
	# returns amount of layers as integer
	def countLayersInLayerGroup(countIdString)
		layerCount = 0

		@idDoc.layers.get.each do |layer|
			if(layer.name.get.to_s[0, 2] == countIdString) then  
				layerCount += 1 
			end
		end

		return layerCount
	end


	##
	# Get all page items by page and with these items an array of layers that are used on this page
	# 
	# return array with layer hashes
	def getLayers(page)
		i 			= 0
		items		= getPageItemsLayerIds(page)
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

				log('getLayers > ID', layer.id_.get.to_s)
				layer_arr << layer_hash
				i += 1
			end
		end
		return layer_arr
	end

	##
	# creates array of pages items by page
	#
	# return array if page item layer_id's
	def getPageItemsLayerIds(page)
		items_arr = Array.new

		@idDoc.pages[its.id_.eq(page)].all_page_items.get.each do |item|
			items_arr  << item.item_layer.id_.get
		end

		return items_arr
	end
	
	def getDimensionInPixels(dimension)
		return (dimension/25.4 *100).round
	end	

	def exec_exportPackedINDD(doc,packPath)
		log('Copying INDD in bundle using path',packPath)
		@idApp.package(doc, :to => MacTypes::FileURL.path(packPath).hfs_path, :ignore_preflight_errors => :yes, :including_hidden_layers => :yes, :copying_profiles => :no, :creating_report => :yes, :copying_fonts => :yes, :updating_graphics => :no, :copying_linked_graphics => :yes)
	end

	def exec_exportPDF(doc,destpdf,preset)
		tmpdestpdf	= '/tmp/'+helper_newtempname(9)+'.pdf'

		log("exporting using output file",destpdf)
		log('exporting PDF to tmp path',tmpdestpdf)
		@idApp.transparency_preference.blending_space.set(:to => :CMYK)
		#TODO CHECK IF PRESET EXISTS
        @idApp.export(doc, :format => :PDF_type, :to => MacTypes::FileURL.path(tmpdestpdf).hfs_path, :timeout => 0, :showing_options => false, :using => preset)

		log('moving pdf from tmp dir',tmpdestpdf)
		log('to output dir',destpdf)
		FileUtils.mv(tmpdestpdf,destpdf)
	end

	def exec_setSwfDefaultOptions
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

	def exec_exportSWF(doc,destSwfFilePath)
		if(@idApp.to_s == "app(\"/Applications/Adobe InDesign CS4 Debug/Adobe InDesign CS4.app\")")

			#destSwfDir		= @outputPath+'PAS3-Flash'
			destSwfDir		= File.dirname(destSwfFilePath)

			FileUtils.mkdir(destSwfDir)

			log('exporting SWF using path',destSwfFilePath)
			@idApp.export(doc, :format => :SWF, :to => MacTypes::FileURL.path(destSwfFilePath).hfs_path, :showing_options => false, :timeout => 0)
		else
			log("Can't export SWF. SWF export is only available in Indesign versions > CS3","") 
		end
	end

	#use PDF export
	def exec_exportPNG(doc,destPngPath)

		log('exporting PNG using path',destPngPath)

		pixWidth	= getDimensionInPixels(getDimensionInPixels(doc.document_preferences.page_width.get))
		pixHeight	= getDimensionInPixels(getDimensionInPixels(doc.document_preferences.page_height.get))

		tmpEpsFile	= '/tmp/'+helper_newtempname(9)+'.eps'
		tmpPngFile	= '/tmp/'+helper_newtempname(9)+'.png'

		exec_exportEPS(doc, tmpEpsFile, pixWidth, pixHeight)

		ci = P3Indesignfranchise_coreimg.new()
		ci.epsToPng(tmpEpsFile, tmpPngFile);
		ci.cropBitmap(tmpPngFile, destPngPath, pixWidth, pixHeight)

		`rm #{tmpPngFile}`
		`rm #{tmpEpsFile}`
	end

   	#depreciated replace everywhere with exec_exportPNG use new functions
	def exec_exportEPS(doc, dest, pixWidth, pixHeight)
		if(@idApp.to_s.downcase.match(/server/))
			@idApp.export(doc, :format => :EPS_type, :to => MacTypes::FileURL.path(dest).hfs_path)
		else
			@idApp.export(doc, :format => :EPS_type, :to => MacTypes::FileURL.path(dest).hfs_path, :showing_options => false)
		end
	end
	
	#depreciated replace everywhere with exec_exportPNG
	def exportEPS(doc, orig, dest, pixWidth, pixHeight)
        #exportToPNGUsingGSIMPDF(doc, orig, dest, pixWidth, pixHeight)
        exportToPNGUsingCGPDF(doc, orig, dest, pixWidth, pixHeight)
    end
        
	#depreciated replace everywhere with exec_exportPNG
	def exportToPNGUsingGSIMPDF(doc, orig, dest, pixWidth, pixHeight)
		if(!@dryrun)
			if(@idApp.to_s.downcase.match(/server/))
				@idApp.export(doc, :format => :PDF_type, :to => MacTypes::FileURL.path(orig).hfs_path)
			else
				@idApp.export(doc, :format => :PDF_type, :to => MacTypes::FileURL.path(orig).hfs_path, :showing_options => false)
			end

			cmd = "/opt/local/bin/gs -dAlignToPixels=0  -dBATCH -dNOPAUSE -dQUIET -dUseCIEColor -sDEVICE=pngalpha -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -r100x100 -sOutputFile=#{dest} #{orig};"
			`#{cmd}`
			cmd = "/opt/local/bin/convert -units PixelsPerInch -density 72x72 -crop #{pixWidth}x#{pixHeight}+0+0 #{dest} #{dest}"
			`#{cmd}`
            FileUtils.rm(orig)
		end
	end
    

    
    #### Latest export method using CoreGraphics cli app
    def exportToPNGUsingCGPDF(doc, orig, dest, pixWidth, pixHeight)
        #log('set pdf type acrobat 5','')
        @idApp.PDF_export_preferences.acrobat_compatibility.set(:to => :acrobat_8)
        #        @idApp.export(doc, :format => :PDF_type, :to => MacTypes::FileURL.path(orig).hfs_path, :timeout => 0, :showing_options => false,:using => '[Smallest File Size]')
        @idApp.export(doc, :format => :PDF_type, :to => MacTypes::FileURL.path(orig).hfs_path, :timeout => 0, :showing_options => false)
    
        cmd1 = "#{RAILS_ROOT}/vendor/MacApplications/pdfrasterize -t -o #{@outputPath} -f png #{orig}"
        system(cmd1)
    
        resizeBitmap(dest,pixWidth,pixHeight)
    
        FileUtils.rm(orig)
    end   
  
    def resizeBitmap(img,pixWidth,pixHeight)
        resizeBitmapUsingIMck(img,pixWidth,pixHeight)  
        #cropBitmapUsingCG(img,pixWidth,pixHeight)
    end
    
    #not used, do we need cropping?
    def cropBitmapUsingCG(img,pixWidth,pixHeight)		        
		ci = P3Indesignfranchise_coreimg.new()
        ci.cropBitmap(tmpPngFile, img, pixWidth, pixHeight)
    end
    
    def resizeBitmapUsingIMck(img,pixWidth,pixHeight)
        cmd3 = "/opt/local/bin/convert -units PixelsPerInch -density 72x72 -crop #{pixWidth}x#{pixHeight}+0+0 #{img} #{img}"
        `#{cmd3}`
    end

    
    
end 
