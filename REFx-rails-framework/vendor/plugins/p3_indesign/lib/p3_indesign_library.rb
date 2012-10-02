class P3Indesign_library
	
	include Appscript
    
	def initialize(filePath,  relPath,  outputPath, idApp)
		@filePath		= filePath
		@relPath		= relPath
		@outputPath		= outputPath
		@idApp			= idApp
        
		P3libLogger::log('Using file', @filePath)
		P3libLogger::log('Using outputPath', @outputPath)
		P3libLogger::log('Using relPath', @relPath)
		P3libLogger::log('Using Indesign Version', @idApp.to_s)
	end
    
	def closeAllDocsNoSave
        
		@idApp.documents.get.each do |doc|
			doc.close(:saving => :no)
            P3libLogger::log("Closing all Indesign open documents:", '')
		end
	end
    
	private
    
	def helper_newtempname(len)
		chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
		newpass = ""
		1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
		return newpass
	end
    
	# log function
	def log(key,val, type = 'info')
        P3libLogger::log("DEPRECIATED LOG."+key,val, type)
	end
    
	# shortcut for log
	def l(key)
		log(key,'')
	end
    
	# open indesign document and return document object
	def openDoc(filepath)
        P3libLogger::log("Opening Indesign document:", filepath)
        
		ret_doc	= @idApp.open(MacTypes::FileURL.path(filepath).hfs_path)
        
		P3libLogger::log("Set preflight off","")
		@idApp.preflight_option.preflight_off.set(:to => :yes)
        
		unlock(ret_doc)
		breakGroups(ret_doc)
		alterDisplaySettings
        
		return ret_doc
	end
    
	# closes the indesign document object
	# TODO use another way to get filepath
	def closeDoc(doc)
		P3libLogger::log("Closing Indesign document:", @filePath)
		doc.close(:saving => :no)
	end
    
	# set doc setting to optimize speed and no interactivity
	def alterDisplaySettings
		@idApp.script_preferences.user_interaction_level.set(:never_interact)
		@idApp.display_performance_preference.ignore_local_settings.set(:to => true)
		@idApp.display_performance_preference.default_display_settings.set(:to => :optimized)
	end
    
	# unlock all layers in document object
	def unlock(doc)
		doc.layers.get.each do |layer|
			@idApp.set(layer.visible, :to => true)
			@idApp.set(layer.locked, :to => false)
			@idApp.set(layer.visible, :to => false)
		end
	end
    
	# make all layers visible in document object
	def allVisible(doc)
		doc.layers.get.each do |layer|
			@idApp.set(layer.visible, :to => true)
		end
	end
    
	# ungroup everyting in document object
	def breakGroups(doc)
		groups = doc.groups.get
        
		groups.each do |group|
			group.ungroup
		end
        
		if (doc.groups.get.length > 0) then breakGroups(doc) end
	end
    
    
    #	def helperInDesignSideToP3Side(side)
    #		return side.to_s[0,side.to_s.index('_')]
    #	end
    
	# convert indesign dimension to screen pixel
	def getDimensionInPixels(dimension)
		return (dimension/25.4 *100).round
	end
	#
	# return arbritary string with strlength characters
	def newtempname( strlength )
		chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
		newpass = ""
		1.upto(strlength) { |i| newpass << chars[rand(chars.size-1)] }
		return newpass
	end
    
	
    
	# set default EPS Output options
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
		@idApp.EPS_export_preferences.image_data.set(:to => :all_image_data)
		@idApp.EPS_export_preferences.EPS_color.set(:to => :RGB)
		@idApp.EPS_export_preferences.OPI_image_replacement.set(:to => false)
		@idApp.EPS_export_preferences.omit_bitmaps.set(:to => false)
		@idApp.EPS_export_preferences.EPS_spreads.set(:to => false)
		@idApp.EPS_export_preferences.preview.set(:to => :none)
		@idApp.EPS_export_preferences.applied_flattener_preset.set(:to => "[Low Resolution]")
		@idApp.EPS_export_preferences.font_embedding.set(:to => :none)
	    @idApp.EPS_export_preferences.image_data.set(:to => :proxy_image_data)
	end
    
	def isPresetAvailable(preset)
        
		@idApp.PDF_export_presets.get.each do |item |
			if(item.name.get == preset)
				return true
			end
		end
		return false
	end
    
	def exec_exportPDF(doc,destpdf,preset)
        
		tmpdestpdf      = '/tmp/'+helper_newtempname(9)+'.pdf'
        @idApp.PDF_export_preferences.page_range.set(:to => 'all pages')
		@idApp.transparency_preference.blending_space.set(:to => :CMYK)
		P3libLogger::log("exporting using preset",preset.to_s)
        P3libLogger::log("exporting using output file",destpdf)
        P3libLogger::log('exporting PDF to tmp path',tmpdestpdf)
        
		@idApp.export(doc, :format => :PDF_type, :to => MacTypes::FileURL.path(tmpdestpdf).hfs_path, :timeout => 0, :showing_options => false, :using => preset.to_s)
        P3libLogger::log('moving pdf from tmp dir',tmpdestpdf)
        P3libLogger::log('to output dir',destpdf)
		FileUtils.mv(tmpdestpdf,destpdf)
	end
  
    
	# Exports EPS and converts this to PNG.
	# The only way to get an alpha tranparant bitmap from inDesign
	#
	# * doc inDesign Document Object
	# * orig the to be created EPS filepath
	# * dest the destined PNG filepath
	# * pixWidth the output width in pixel
	# * pixHeight the output height in pixel
	#
	# NOTE gives problems using InDesign Server inside VMWARE
	def exportPNGviaEPS(doc, orig, dest, pixWidth, pixHeight)
        P3libLogger::log('WARNING THIS METHOD exportPNGviaEPS IS NOT USED ANYMORE')
	end
    
	# set default JPEG Output options
	def setJpegExportOptions(page)
        
		@idApp.JPEG_export_preferences.JPEG_export_range.set(:to => :export_all)
		@idApp.JPEG_export_preferences.JPEG_Quality.set(:to => :low)
		@idApp.JPEG_export_preferences.resolution.set(:to => 72)
        
	end
    
	# export page(s) to JPEG
	def	exportJPEG(doc, dest)
		if(@idApp.to_s.downcase.match(/server/))
			@idApp.export(doc, :format => :JPG, :to => MacTypes::FileURL.path(dest).hfs_path)
            else
			p dest
			@idApp.export(doc, :format => :JPG, :to => MacTypes::FileURL.path(dest).hfs_path, :showing_options => false)
		end
	end
end
