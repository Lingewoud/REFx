# P3libImage
#TODO REMOVE
#require 'osxfix'

## library for all helper image classes

class P3libIndesign
    
    public

    #### Latest export method using CoreGraphics cli app
    def self.exportToPNG(inDesignApp, doc, outputPath, orig, dest, pixWidth, pixHeight)
        
    #P3libLogger::log('set pdf type acrobat 8','')
        inDesignApp.PDF_export_preferences.acrobat_compatibility.set(:to => :acrobat_8)
        inDesignApp.export(doc, :format => :PDF_type, :to => MacTypes::FileURL.path(orig).hfs_path, :timeout => 0, :showing_options => false)        

        cmd1 = "#{RAILS_ROOT}/vendor/MacApplications/pdfrasterize -t -o #{outputPath} -f png #{orig}"
        
        P3libLogger::log('rasterize:dest'+dest,cmd1)
        system(cmd1)
    
        P3libImage::resizeBitmap(dest,pixWidth,pixHeight)
        FileUtils.rm(orig)
    end


end

