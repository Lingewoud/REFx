require "pp"
require 'base64'
require 'fileutils'
require 'rubygems'
require 'appscript' 

class P3gaIndesign
	
	include Appscript
	@errorArr=nil
	@warningArr=nil

	def initialize(jobId,remoteDummyRootDir, relSrcFilePath, relOutputBasePath, inApplication='Adobe InDesign CS4',dryRun=true)
	#def initialize(working_dir_root, repository_root, outputPath, filePath, test = false)

		remoteDummyRootDir = Base64.decode64(remoteDummyRootDir)
		relSrcFilePath = Base64.decode64(relSrcFilePath)
		relOutputBasePath = Base64.decode64(relOutputBasePath)

		@filePath	=  File.join(remoteDummyRootDir,relSrcFilePath)
		@remoteDummyRootDir = remoteDummyRootDir

		@relOutputBasePath = relOutputBasePath

		@relPath =  relOutputBasePath + '/' + jobId + '/'

		@outputPath = File.join(remoteDummyRootDir,@relPath) 


		





		FileUtils.mkdir(@outputPath) if not File.directory? @outputPath
		
		@outputPath += '/'
		
		@logger = Logger.new("#{RAILS_ROOT}/log/pas3.log")
		@logger.level = Logger::DEBUG
		@logger.info Time.now.to_s+': Using file' +@filePath;
		@logger.info Time.now.to_s+': Using workingdir'+ @outputPath;
		@logger.info Time.now.to_s+': Using relative working Path'+ @relPath;

		@xml		= P3gaXMLParser.new()
		@hr			= P3gaHrParser.new()
		@debug		= P3gaDebug.new()
		#@idApp		= (test == true) ? app('Adobe InDesign CS3') : app('InDesignServer')
		@idApp		= app('Adobe InDesign CS4')
		#@idApp.activate()
	end

	# public functions
	public

	def testMe()
		return 'hello'
	end

	def dryRun(dryrun)
		@dryrun = dryrun
	end

	def certifyDocument(previewJobId,newFileName)

		previewFile = File.join(@remoteDummyRootDir,@relOutputBasePath,previewJobId.to_s, 'finalpreview.pdf') 
		@logger.info Time.now.to_s+': certitiing'+ previewFile + " to " + newFileName;
		FileUtils.cp(previewFile,  '/Users/machinist/pitstop/NL/IN/'+newFileName)

		sleep(4)
		newOrderFolder = File.join(@remoteDummyRootDir,@relOutputBasePath + '/' + previewJobId.to_s + '/') 

		FileUtils.cp('/Users/machinist/pitstop/NL/OUT/'+newFileName, newOrderFolder)



		#copy preview doc to pitstop in with correct naming
		#check for file if it exists  with timeout
		return 'ok'
	end

	def getErrors
		return @errorArr
	end

	def getWarnings
		return @warningArr
	end

	def getXML
		openDoc
		document = Hash.new

		breakGroups

		#FIXME add information about books, spreads, position pages on spread, etc to array
		document[:layerGroups] = getLayerGroups()
		document[:preview]		= @relPath+'sourcedoc.png'
		document[:width]		= getDimensionInPixels(@idDoc.document_preferences.page_width.get)
		document[:height]		= getDimensionInPixels(@idDoc.document_preferences.page_height.get)

		closeDoc
		return @xml.convertXML(document, false)
	end

	def getExtendedXML
		openDoc

		setAllLayersVisibleUnlocked

		document = Hash.new

		breakGroups

		#FIXME add information about books, spreads, position pages on spread, etc to array
		document[:layerGroups] = getLayerGroups()
		document[:preview]		= @relPath+'sourcedoc.png'
		document[:width]		= getDimensionInPixels(@idDoc.document_preferences.page_width.get)
		document[:height]		= getDimensionInPixels(@idDoc.document_preferences.page_height.get)

		closeDoc
		return @xml.convertXML(document, true)
	end

	def getHumanReadable
		openDoc
		dryRun(true)

		document = Hash.new

		breakGroups

		#FIXME add information about books, spreads, position pages on spread, etc to array
		document[:layerGroups] = getLayerGroups()
		document[:preview]		= @relPath+'sourcedoc.png'
		document[:width]		= getDimensionInPixels(@idDoc.document_preferences.page_width.get)
		document[:height]		= getDimensionInPixels(@idDoc.document_preferences.page_height.get)

		closeDoc
		return @hr.convertHr(document)
	end

	def getPreview
		docArray = getDocArray

		return docArray[:preview]
	end

	def getFinalPreview(xmlencoded)
		xml= Base64.decode64(xmlencoded)
		xml= Base64.decode64(xml)
		#xml= base64Utf8Workaround(xmlencoded)
		@logger.info Time.now.to_s+': starting final Preview'
		log('encoded',xmlencoded)
		log('decoded',xml)
		#log('test','Håå')
		#return 'hallo'
		newHash = Hash.from_xml(xml)
	
		openDoc
		
		layers = getLayersSimple

		layers.each do |layer|
			layerId = layer[:name].to_s[0, 2]
			@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].visible, :to => false)
		end

		# for each group set selected layer visible
		newHash['document']['layerGroups'].each do |layerGroup|
			layerGroup.each do |child|
				if child.class.to_s == "Hash"
					child.each do |lay|
						lay.each do |child2|
							if child2.class.to_s == "Hash"
								#@logger.info Time.now.to_s+': child2:: '+  child2.to_yaml
								lID = child2['layerID'].to_i
								@idApp.set(@idDoc.layers[its.id_.eq(lID)].visible, :to => true)

								if not  child2['layerChilds'].nil?
									child2['layerChilds'].each do |childkey,childval|

										#get layer child, check type
										#if type is merge set content
										@idDoc.layers[its.id_.eq(lID)].page_items.get.each do |pitem|
											pitemobject = pitem.get
											if is_mergeTextField(pitem)
												if( pitem.id_.get.to_s == childkey[5..-1].to_s)

													@idDoc.set(pitemobject.contents, :to => childval.strip)

													if pitem.label.get.to_s.downcase.index('dealername') != nil

														while @idDoc.get(pitem.overflows).to_s == 'true'
															pointS = @idDoc.get(pitem.text.point_size)
															par = @idDoc.get(pitem.paragraphs.object_reference, :result_type => :list)
															par.each do |para|
																@idDoc.set(para.point_size, :to => pointS[0].to_i-1 )
															end
														end

													elsif pitem.label.get.to_s.downcase.index('dealeraddress') != nil 

														cnt = ''
														lines = @idDoc.get(pitem.lines.object_reference, :result_type => :list)
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
															@idDoc.set(pitemobject.contents, :to => cnt)
														end
													end
												end
											end	
										end
									end
								end
							end
						end
					end
				end
			end
		end
	

		# export pdf (for later)
		
		# export png
#		orig	= @outputPath+'finalpreview.eps'
#		orig2	= '/Users/machinist/Desktop/finalpreview.eps'

#		dest	= @outputPath+'finalpreview.png'
		
#		dest	= '/Users/machinist/Desktop/finalpreview.eps'
#		dest	= '/Users/machinist/Desktop/finalpreview.png'
		destpdf	= '/Users/machinist/Desktop/finalpreview.pdf'
#		desteps	= '/Users/machinist/Desktop/finalpreview.eps'

		orig	= @outputPath+'finalpreview.eps'
		dest	= @outputPath+'finalpreview.png'
#		destpdf	= @outputPath+'finalpreview.pdf'

		#@idApp.export(@idDoc, :format => :JPG, :to => MacTypes::FileURL.path(destjpg).hfs_path, :showing_options => false)
#		@idApp.export(@idDoc, :format => :PDF_type, :to => MacTypes::FileURL.path(destpdf).hfs_path, :showing_options => false, :using => 'PDFX1Swe_Newspaper2006')
		@idApp.export(@idDoc, :format => :PDF_type, :to => MacTypes::FileURL.path(destpdf).hfs_path, :showing_options => false, :using => 'TUNews07PDFX1a2001')

		#@idApp.export(@idDoc, :format => :PDF_type, :to => MacTypes::FileURL.path(orig).hfs_path, :showing_options => false, :using => 'PDFX1Swe_Newspaper2006')
		#$export this_image format PDF type to my unix2MacPath("<?=$this->pdf_file?>") using "<?=$this->pdf_profile?>" without showing options

		doConvert=false
		if(doConvert)
			@idApp.export(@idDoc, :format => :EPS_type, :to => MacTypes::FileURL.path(orig).hfs_path, :showing_options => false)
			pixWidth	= getDimensionInPixels(getDimensionInPixels(@idDoc.document_preferences.page_width.get))
			pixHeight	= getDimensionInPixels(getDimensionInPixels(@idDoc.document_preferences.page_height.get))
			ci = P3Indesign_coreimg.new()
			@logger.info Time.now.to_s+': eps to png:'+ orig + " to " + dest;
			ci.epsToPng(orig, File.dirname(dest)+'/_'+File.basename(dest));
			@logger.info Time.now.to_s+': cropping:'+ dest + " to " + pixWidth.to_s + "x" + pixHeight.to_s;
			ci.cropBitmap(File.dirname(dest)+'/_'+File.basename(dest), dest, pixWidth, pixHeight)

			#FIXME Convert images using Ruby Coccoa"
#			cmd = "gs -dSAFER -dAlignToPixels=0 -dEPSCrop -dBATCH -dNOPAUSE -dQUIET -sDEVICE=png16m -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -r100x100 -sOutputFile=#{dest} #{orig};"
#			log(cmd)
#			cmd += "convert -units PixelsPerInch -density 72x72 -crop #{pixWidth}x#{pixHeight}+0+0 #{dest} #{dest}"

			#t = Thread.new { `#{cmd} `}
		end

		dest	= @outputPath+'finalpreview.png'
		exec_exportPNG(@idDoc, dest)


#		FileUtils.mv(destjpg,  @outputPath+'finalpreview.jpg')
		FileUtils.mv(destpdf,  @outputPath+'finalpreview.pdf')


		closeDoc

		# return png location in result body

	end
    #use PDF export
    def exec_exportPNG(doc,destPngPath)

        P3libLogger::log('exporting PNG using path',destPngPath)

        pixWidth    = getDimensionInPixels(getDimensionInPixels(doc.document_preferences.page_width.get))
        pixHeight   = getDimensionInPixels(getDimensionInPixels(doc.document_preferences.page_height.get))

        P3libIndesign::exportToPNG(@idApp, doc, @outputPath, @outputPath+"/finalpreview.pdf", destPngPath, pixWidth, pixHeight)
    end
	# private functions
	private

	def log(key,val)
		@logger.info Time.now.to_s+' - '+ key+ ': '+ val
	end

	def openDoc
		@idDoc		= @idApp.open(MacTypes::FileURL.path(@filePath).hfs_path)
	end

	def closeDoc
		@idDoc.close(:saving => :no)
	end

	def setAllLayersVisibleUnlocked
		layers		= getLayersSimple
		layers.each do |layer|
			layerId = layer[:name].to_s[0, 2]
			@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].visible, :to => true)
			@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].locked, :to => false)
		end
	end

	#	def setAllLayersHidden(layers)
	#
	#		layers.each do |layer|
	#			layerId = layer[:name].to_s[0, 2]
	#			@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].visible, :to => false)
	#		end
	#	end

	def getLayerGroups
		layerGroups = Hash.new
		layers		= getLayers
		lastLayer	= ''

		layers.each do |layer|
			@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].visible, :to => false)
		end

		layers.each do |layer|
			@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].visible, :to => true)

			orig	= @outputPath+'layer'+layer[:layerID].to_s+'.eps'
			dest	= @outputPath+'layer'+layer[:layerID].to_s+'.png'

			if(!@dryrun)
				@logger.info Time.now.to_s+': exporting layereps:'+ orig + " to " + dest;
				@idApp.export(@idDoc, :format => :EPS_type, :to => MacTypes::FileURL.path(orig).hfs_path, :showing_options => false)

				#pixWidth	= getDimensionInPixels(getDimensionInPixels(@idDoc.document_preferences.page_width.get)).to_s
				#pixHeight	= getDimensionInPixels(getDimensionInPixels(@idDoc.document_preferences.page_height.get)).to_s
				pixWidth	= getDimensionInPixels(getDimensionInPixels(@idDoc.document_preferences.page_width.get))
				pixHeight	= getDimensionInPixels(getDimensionInPixels(@idDoc.document_preferences.page_height.get))

				ci = P3Indesign_coreimg.new()
				@logger.info Time.now.to_s+': eps to png:'+ orig + " to " + dest;
				ci.epsToPng(orig, File.dirname(dest)+'/_'+File.basename(dest));
				@logger.info Time.now.to_s+': cropping:'+ dest + " to " + pixWidth.to_s + "x" + pixHeight.to_s;
				ci.cropBitmap(File.dirname(dest)+'/_'+File.basename(dest), dest, pixWidth, pixHeight)

				#clean up trash
#				`rm #{File.dirname(dest)+'/_'+File.basename(dest)}`
#				`rm #{orig}`

				#FIXME Convert images using Ruby Coccoa"
#				cmd = "gs -dSAFER -dAlignToPixels=0 -dEPSCrop -dBATCH -dNOPAUSE -dQUIET -sDEVICE=png16m -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -r100x100 -sOutputFile=#{dest} #{orig};"
#				cmd += "convert -units PixelsPerInch -density 72x72 -crop #{pixWidth}x#{pixHeight}+0+0 #{dest} #{dest};"
#				cmd += "convert -alpha Set -background transparent  -trim #{dest} #{dest}"
#				p cmd

				#t = Thread.new { `#{cmd} `}
			end

			@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].visible, :to => false)
		end

		layers.each do |layer|
			layerId = layer[:name].to_s[0, 2]

			if(lastLayer == layerId || layerId == 'xx' || layerId == 'XX') 
				@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].visible, :to => false)
			else
				@idApp.set(@idDoc.layers[its.id_.eq(layer[:layerID])].visible, :to => true)
			end
			
			lastLayer = layerId

			if(layerGroups.keys.to_s.index("group" + layerId) == nil) then layerGroups[eval(":group" + layerId)] = Hash.new end
			layerGroups[eval(":group" + layerId)][eval(":layer"+layer[:layerID].to_s)] = layer			
		end

		orig	= @outputPath+'sourcedoc.eps'
		dest	= @outputPath+'sourcedoc.png'

		if(!@dryrun)
			@idApp.export(@idDoc, :format => :EPS_type, :to => MacTypes::FileURL.path(orig).hfs_path, :showing_options => false)

			pixWidth	= getDimensionInPixels(getDimensionInPixels(@idDoc.document_preferences.page_width.get)).to_s
			pixHeight	= getDimensionInPixels(getDimensionInPixels(@idDoc.document_preferences.page_height.get)).to_s

			#FIXME Convert images using Ruby Coccoa"
			cmd = "gs -dSAFER -dAlignToPixels=0 -dEPSCrop -dBATCH -dNOPAUSE -dQUIET -sDEVICE=png16m -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -r100x100 -sOutputFile=#{dest} #{orig};"
			cmd += "convert -units PixelsPerInch -density 72x72 -crop #{pixWidth}x#{pixHeight}+0+0 #{dest} #{dest}"

			t = Thread.new { `#{cmd} `}
		end

		return layerGroups
	end

	def getCurrentLayerGroup(currLayer)
		layerCount = 0

		@idDoc.layers.get.each do |layer|
			if(layer.name.get.to_s[0, 2] == currLayer) then  layerCount += 1 end
		end

		return layerCount
	end

	def getLayers
		layerArray = Array.new
		i = 0

		@idDoc.layers.get.each do |layer|
			layerProps	= Hash.new{|hash, key| hash[key] = Hash.new}

			layerProps[:layerID]	= layer.id_.get
			layerProps[:name]		= layer.name.get.to_s
			layerProps[:zindex]		= @idDoc.layers.get.length-i
			layerProps[:preview]	= @relPath+'layer'+layer.id_.get.to_s+'.png'
			layerProps[:layerChilds] = getChilds(layer)

			layerArray << layerProps

			i = i+1
		end

		return layerArray
	end

	def getLayersSimple
		layerArray = Array.new
		i = 0

		@idDoc.layers.get.each do |layer|
			layerProps	= Hash.new{|hash, key| hash[key] = Hash.new}

			layerProps[:layerID]	= layer.id_.get
			layerProps[:name]		= layer.name.get.to_s
			#layerProps[:zindex]		= @idDoc.layers.get.length-i
			layerProps[:layerChilds] = getChildsSimple(layer)

			layerArray << layerProps

			i = i+1
		end

		return layerArray

	end

	def getChilds(layer)
		childs = Hash.new{|hash, key| hash[key] = Array.new}
		#FIXME add support for tables

		layer.page_items.get.each do |child|			
			#FIXME add support for ovals, polygons, and graphic lines

			childProps = Hash.new{|hash, key| hash[key] = Array.new}
			geom =  child.geometric_bounds.get

			id		= child.id_.get
			name	= child.get
			label	= child.label.get.to_s
			type	= getType(child)
			width	= geom[3].to_f-geom[1].to_f
			height	= geom[2].to_f-geom[0].to_f
			static	= getStatic(child.label.get.to_s.downcase)

			childProps[:objectID]	= id
			childProps[:label]		= label
			childProps[:type]		= type
			childProps[:x]			= getDimensionInPixels(geom[1])
			childProps[:y]			= getDimensionInPixels(geom[0])
			childProps[:w]			= getDimensionInPixels(width)
			childProps[:h]			= getDimensionInPixels(height)
			childProps[:isStatic]	= static
			childProps[:inGroup]	= (getCurrentLayerGroup(layer.name.get.to_s[0, 2]) > 1) ? true : false
			childProps[:content]    = getContent(name, type, static)
			childProps[:group]		= layer.name.get.to_s[0, 2]
			childProps[:preview]	= exportObject(id, name, type, width, height) 

			#FIXME indesign/appscript gives very 'special' output in case of Pantone colors - ignore for now
			childProps[:background] = 'unknown'  #getBackGroundColor(child)  
			childs["child"+id.to_s] = childProps 
		end

		return childs

	end

	def getChildsSimple(layer)
		childs = Hash.new{|hash, key| hash[key] = Array.new}
		#FIXME add support for tables

		layer.page_items.get.each do |child|			
			#FIXME add support for ovals, polygons, and graphic lines

			childProps = Hash.new{|hash, key| hash[key] = Array.new}
			geom =  child.geometric_bounds.get

			id		= child.id_.get
			name	= child.get
			label	= child.label.get.to_s
			type	= getType(child)
			width	= geom[3].to_f-geom[1].to_f
			height	= geom[2].to_f-geom[0].to_f
			static	= getStatic(child.label.get.to_s.downcase)

			childProps[:objectID]	= id
			childProps[:label]		= label
			childProps[:type]		= type
			#childProps[:x]			= getDimensionInPixels(geom[1])
			#childProps[:y]			= getDimensionInPixels(geom[0])
			#childProps[:w]			= getDimensionInPixels(width)
			#childProps[:h]			= getDimensionInPixels(height)
			childProps[:isStatic]	= static
			childProps[:inGroup]	= (getCurrentLayerGroup(layer.name.get.to_s[0, 2]) > 1) ? true : false
			childProps[:content]    = getContent(name, type, static)
			childProps[:group]		= layer.name.get.to_s[0, 2]
			#childProps[:preview]	= exportObject(id, name, type, width, height) 

			#FIXME indesign/appscript gives very 'special' output in case of Pantone colors - ignore for now
			#childProps[:background] = 'unknown'  #getBackGroundColor(child)  
			childs["child"+id.to_s] = childProps 
		end

		return childs
	end

	def breakGroups
		groups = @idDoc.groups.get

		groups.each do |group|
			group.ungroup
		end

		if (@idDoc.groups.get.length > 0) then breakGroups	end	
	end

	def getStatic(label)
		#NOTE pTextInput & pMergeField = plain text, rTextInput & rMergeField = rich text
		#NOTE all types need an order indication according to the convention _001
		#NOTE mergeTextField need to have an identifier after the order indicator e.g. _003_namefield

		types		= ['textinput', 'imageinput', 'colorinput', 'mergetextfield', 'mergeimgfield'] 
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

	def is_mergeTextField(page_item)
		if page_item.label.get.to_s.downcase.index('mergetextfield') != nil
			return true
		else
			return false
		end
	end

	def getDimensionInPixels(dimension)
		return (dimension/25.4 *100).round
	end

	def getContent(object, type, static)

		if(type == 'text' && static == false)
			content='<![CDATA['
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

				#content	+= "<p id=\"#{lineID}\" style=\"font-family:#{font};font-size:#{fontSize};text-align:#{justification};font-style:#{fontStyle};font-weight:#{fontWeight};letter-spacing:#{spacing};font-size:#{fontScale}%\">#{cnt}</p><br/>"
				if lineI < 1
					content	+= "<p id=\"#{lineID}\" style=\"font-family:#{font};font-size:#{fontSize};text-align:#{justification};font-style:#{fontStyle};font-weight:#{fontWeight};letter-spacing:#{spacing};font-size:#{fontScale}%\">#{cnt}<br/>"
				else
					content	+= "#{cnt}<br/>"
				end

				lineI += 1

			end	
			
			#content += ']]>'
			content += '</p><br/>]]>'
		else
			content	= false
		end

		return content
	end

	def exportObject(object, name, type, width, height)
		nwidth	= (width < 30) ? 30 : width
		nheight = (height < 30) ? 30 : height


		orig	= @outputPath+type.to_s+object.to_s + '.eps'
		dest	= @outputPath+type.to_s+object.to_s+'.png'

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

			tmpDoc.export(tmpDoc, :format => :EPS_type, :to => MacTypes::FileURL.path(orig).hfs_path, :showing_options => false)
			tmpDoc.close(:saving => :no)

			pixWidth	= getDimensionInPixels(width).to_s
			pixHeight	= getDimensionInPixels(height).to_s

			#FIXME Convert images using Ruby Coccoa"
			cmd = "gs -dAlignToPixels=0 -dEPSCrop -dBATCH -dNOPAUSE -dQUIET -sDEVICE=pngalpha -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -r100x100 -sOutputFile=#{dest} #{orig};"
			cmd += "convert -units PixelsPerInch -density 72x72 -crop #{pixWidth}x#{pixHeight}+0+0 #{dest} #{dest}"

			t = Thread.new { `#{cmd} `}
		end

		return @relPath+type.to_s+object.to_s+'.png'
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

	def base64Utf8Workaround(enc_str)

		tmpfilename_in= "#{RAILS_ROOT}/tmp/base64tonormal_in.txt"
		tmpfilename_out= "#{RAILS_ROOT}/tmp/base64tonormal_out.txt"
#		tmpfilename_out="tmp/base64tonormal_out.txt"
		tmpConvertFile = File.new(tmpfilename_in, 'w')
		#tmpConvertFile = File.new(tmpfilename_in, File::TRUNC)
		tmpConvertFile.puts enc_str
		tmpConvertFile.close()
		
		#perl
		cli= "perl -MMIME::Base64 -ne 'print decode_base64($_)' < "+ tmpfilename_in +" > " + tmpfilename_out
		system(cli)
		
		File.delete(tmpfilename_in)

		#read decode
		dec_str = ''
		File.open(tmpfilename_out, 'r') do |f1|  
			while line = f1.gets  
				dec_str += line  
			end  
		end 
		#File.delete(tmpfilename_out)
		return dec_str
	end
end

