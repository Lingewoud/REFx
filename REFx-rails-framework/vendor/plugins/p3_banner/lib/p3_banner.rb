require 'fileutils'
require 'rubygems'
require 'appscript'
require 'base64'

class P3Banner
    
	include Appscript
    
	# Reads the main configuration arguments of the PAS3 Indesign Engine
	def initialize(jobId,remoteDummyRootDir, relSrcFilePath, relOutputBasePath, inApplication='Adobe Flash CS6',dryRun=true, noObjectExport=false)
        
        P3libLogger::log('Hello, i am a FLASH BANNER')
        P3libLogger::log('Doing some init stuff...')
        
        remoteDummyRootDir = Base64.decode64(remoteDummyRootDir)
		relSrcFilePath = Base64.decode64(relSrcFilePath)
		relOutputBasePath = Base64.decode64(relOutputBasePath)
                        
		# 'Adobe Flash CS3'
		# 'Adobe Flash CS4'
		# 'InDesignServer'
		#
        
        P3libLogger::log(remoteDummyRootDir)
        P3libLogger::log(relSrcFilePath)
        P3libLogger::log(relOutputBasePath)
        
		@idApp = (inApplication == 'Adobe Flash CS6') ? app(inApplication) : app(Base64.decode64(inApplication))
        
		@dryRun			= dryRun
		@noObjectExport = noObjectExport

        @relSrcFilePath = relSrcFilePath
		@remoteDummyRootDir = remoteDummyRootDir
        
        if remoteDummyRootDir.nil?
			@AbsSrcFilePath	=  relSrcFilePath
        else
			@AbsSrcFilePath	=  File.join(remoteDummyRootDir,relSrcFilePath)
			$remoteDummyRootDir = remoteDummyRootDir # Not, nice but needed for getting images in de banner_import class
		end
        
		if jobId.nil?
			@relOutputPath 	= relOutputBasePath + '/'
        else
			@jobId = jobId
			@relOutputPath 	= File.join(relOutputBasePath,@jobId) + '/'
		end

		@absOutputPath 		= File.join(@remoteDummyRootDir,relOutputBasePath,@jobId)
        
		FileUtils.mkdir(@absOutputPath) if not File.directory? @absOutputPath if not dryRun
        
		@absOutputPath += '/'
    end

    public
    
    def modConfigJSFL(input=false, id=0)

        if(input)
            path = '/Users/maartenvanhees/Source/GitHub/REFx3/REFx-rails-framework/JSFL/import.jsfl'
        else
            path = '/Users/maartenvanhees/Source/GitHub/REFx3/REFx-rails-framework/JSFL/export.jsfl'
        end
    
        data = '';
        
        f = File.open(path, "r")
        #relOutPath moet zonder jobId in dit geval
        P3libLogger::log(@relOutputPath)

        relarray = @relOutputPath.split('/')
        relarray.delete(@jobId)
        newRelPath = relarray.join('/')
        
        f.each_line do |line|
            
            line2 = line.gsub(/\s/,'')
            
            documentNameData = line2.gsub(/documentName\:/,'')
            jobIdData = line2.gsub(/jobID\:/,'')
            outputBasePathData = line2.gsub(/outputBasePath\:/,'')
            outputFileData = line2.gsub(/outputFileName\:/,'')
            outputFolderData = line2.gsub(/outputFolder\:/,'')
            
            if documentNameData != line2
                data += "documentName:'file://" + @AbsSrcFilePath + "',\n"
            elsif jobIdData != line2
                if(input)
                    data += "jobID:'" + id.to_s() + "',\n"
                else
                    data += "jobID:'" + @jobId + "',\n"
                end
            elsif outputFileData != line2
                data += "outputFileName:'output',\n"
            elsif outputFolderData != line2
                data += "outputFolder:'" + newRelPath + "/',\n"
            elsif outputBasePathData != line2
                data += "outputBasePath:'file://" + @remoteDummyRootDir + "/',\n"
            else
                data += line
            end                      
        end

        if input
            file = 'import_' + @jobId + '.jsfl'
        else
            file = 'export_' + @jobId + '.jsfl'
        end
            
        path = '/Users/maartenvanhees/Source/GitHub/REFx3/REFx-rails-framework/JSFL/' + file
        
        File.open(path, 'w') {|f| f.write(data) }
    end
    
    def indexFile()
        
        modConfigJSFL();
        
        file = "export_" + @jobId + ".jsfl"
        
        cmd = "osascript -e 'tell application \"Adobe Flash CS6\" to open \"#{RAILS_ROOT}/JSFL/export_"+@jobId+".jsfl\"'"
        
        system(cmd)
    end
    
    def getSWF(answerxml, id)
        
        P3libLogger::log("Me, FLASH BANNER, am getting a swf now")

        #we moeten de huidige id geven aan de config, want we moeten de swf in de geindexeerde map knallen, naast de dingen die er nog naast moeten
        
        modConfigJSFL(true, id)
        
        cmd = "osascript -e 'tell application \"Adobe Flash CS6\" to open \"#{RAILS_ROOT}/JSFL/import_"+@jobId+".jsfl\"'"
        
        system(cmd)
    end
 end
