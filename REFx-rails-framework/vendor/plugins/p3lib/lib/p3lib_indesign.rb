# P3libIndesign

## library with indesign class methods

class P3libIndesign
    
    public

    #### Latest export method using CoreGraphics cli app
    #orig is the inbetween pdf file which us used to generate a PNG with alpha channel
    def self.exportToPNG(inDesignApp, doc, outputPath, orig, dest, pixWidth, pixHeight)

        # TODO make preference
        native = false
    
        # inDesigns PNG export is only available in CS6 and doesn't work well for layers (in case of embedded PSD's)
        if(native && inDesignApp.to_s == "app(\"/Applications/Adobe InDesign CS6/Adobe InDesign CS6.app\")" && !dest.index('layer'))
    
            nativeExportToPNG(inDesignApp, doc, dest)
            
        else
            P3libLogger::log('Exporting to PNG using PDF as between file','','debug')

            inDesignApp.transparency_preference.blending_space.set(:to => :CMYK)
            inDesignApp.PDF_export_preferences.acrobat_compatibility.set(:to => :acrobat_8)
        begin
                inDesignApp.export(doc, :format => :PDF_type, :to => MacTypes::FileURL.path(orig).hfs_path, :timeout => 0, :showing_options => false)
            rescue Exception => e
                P3libLogger::log('PNG export failed: '+ e.message, 'error')
            end
    
            cmd1 = "#{RAILS_ROOT}/vendor/MacApplications/pdfrasterize -s 2.0 -t -o '#{outputPath}' -f png '#{orig}'"
    
            P3libLogger::log('rasterize:dest'+dest,cmd1)
            system(cmd1)
            P3libImage::resizeBitmapByWidth(dest,pixWidth)
    
            if($debug)
                P3libLogger::log('exportToPNG:'+orig+' w:'+pixWidth.to_s+' h:'+pixHeight.to_s,'')
                P3libLogger::log('exportToPNG:'+File.basename(orig)+' w:'+pixWidth.to_s+' h:'+pixHeight.to_s,'')
            else
                FileUtils.rm(orig)
            end
        end
    end

    def self.nativeExportToPNG(inDesignApp, doc, dest)

        if(!dest.index('image'))

            begin
                inDesignApp.export(doc, :format => :PNG_format, :to => MacTypes::FileURL.path(dest).hfs_path, :timeout => 0, :showing_options => false)
            rescue Exception => e
                P3libLogger::log('PNG export failed: '+ e.message, 'error')
            end
        else
            # If is type image the image could be a PSD which can't be exported using inDesign's PNG export
            # Use HTML export instead (apparently Indesign can export PSD as PNG, it can't do so using the PNG export method)
            
            # Turn preview after export off
            doc.HTML_export_preference.view_document_after_export.set(:to => false)
            
            # Some other export preferences - not tested yet
            #doc.HTML_export_preference.image_conversion.set(:to => :PNG)
            #doc.HTML_export_preference.image_export_resolution(:to => 150)
            #doc.HTML_export_preference.CSS_export_option.set(:to => :none)
            #doc.HTML_export_preference.ignore_object_conversion_settings.set(:to => false)
            #doc.HTML_export_preference.level.set(:to => 6) #PNG level
            
            # Export HTML
            begin
                inDesignApp.export(doc, :format => :HTML, :to => MacTypes::FileURL.path(dest+'.html').hfs_path, :timeout => 0, :showing_options => false)
                rescue Exception => e
                P3libLogger::log('HTML export failed: '+ e.message)
            end
            
            # Copy PNG file from the HTML's web-resources folder to destination
            Dir.foreach(dest+'-web-resources/image'){|f|
                if(f != '.' && f != '..')
                    FileUtils.cp(dest+'-web-resources/image/'+f, dest)
                end
            }
            
            # Clean up - prevents folders postfixed with numbers at reindex
            FileUtils.rm_rf(dest+'-web-resources/')
            FileUtils.rm(dest+'.html')
            
        end
    end


    def self.placeImageOnItem(item, absolute_img_src)
        if(File.exists?(absolute_img_src) && File.readable?(absolute_img_src) && File.file?(absolute_img_src))
            

        begin
            P3libLogger::log("placing item normal", MacTypes::FileURL.path(absolute_img_src).to_s)
            item.place(MacTypes::FileURL.path(absolute_img_src))
        rescue
            begin
                P3libLogger::log("placing item hfs", MacTypes::FileURL.path(absolute_img_src).hfs_path.to_s)
                item.place(MacTypes::FileURL.path(absolute_img_src).hfs_path)
            rescue
                P3libLogger::log("unable to place item", "")
            end
        end
        else
                P3libLogger::log("image file not usable", absolute_img_src)
        end
    end

    def self.closeAllDocsNoSave(inDesignApp)
        begin
            inDesignApp.documents.get.each do |doc|
                doc.close(:saving => :no)
                P3libLogger::log("Closing all Indesign open documents:", '')
            end
        rescue
            P3libLogger::log("unable to close all open documents", "",'error')
        end
        
    end


end

