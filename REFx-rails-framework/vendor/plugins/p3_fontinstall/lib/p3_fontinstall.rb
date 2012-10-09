# P3Saywhat

require 'rubygems'
require 'appscript' 
require 'base64'
require 'osax'

class P3Fontinstall
    include Appscript
    
    def initialize(jobId,remoteDummyRootDir, fontDir)
		
        remoteDummyRootDir = Base64.decode64(remoteDummyRootDir)
        fontDir = Base64.decode64(fontDir)

		if not remoteDummyRootDir.nil?
			@fontDir	=  File.join(remoteDummyRootDir,fontDir)
		end
    end

    def installFontsInDir
        P3libLogger::log('Font Source Path'+@fontDir)
        Dir.open(@fontDir).each { |file|
            ext =File.extname(file).downcase
            if(ext == '.ttf' || ext=='.otf')
                P3libLogger::log('installing in /Library/Fonts/: '+file)
                FileUtils.cp(@fontDir + "/" + file, '/Library/Fonts/')
            end
        }
        
        return ''
    end
end
