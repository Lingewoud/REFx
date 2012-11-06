# P3libIndesign

## library with indesign class methods

class P3libIndesign
    
    public

    #### Latest export method using CoreGraphics cli app
    #orig is the inbetween pdf file which us used to generate a PNG with alpha channel
    def self.exportToPNG(inDesignApp, doc, outputPath, orig, dest, pixWidth, pixHeight)
        
        inDesignApp.PDF_export_preferences.acrobat_compatibility.set(:to => :acrobat_8)
        inDesignApp.export(doc, :format => :PDF_type, :to => MacTypes::FileURL.path(orig).hfs_path, :timeout => 0, :showing_options => false)
        
        cmd1 = "#{RAILS_ROOT}/vendor/MacApplications/pdfrasterize -s 2.0 -t -o #{outputPath} -f png #{orig}"
        
        #P3libLogger::log('rasterize:dest'+dest,cmd1)
        system(cmd1)
        
        #P3libLogger::log('exportToPNG:'+orig+' w:'+pixWidth.to_s+' h:'+pixHeight.to_s,'')
        #P3libLogger::log('exportToPNG:'+File.basename(orig)+' w:'+pixWidth.to_s+' h:'+pixHeight.to_s,'')

        P3libImage::resizeBitmapByWidth(dest,pixWidth)
        FileUtils.rm(orig)
    end


end

