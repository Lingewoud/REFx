require 'rubygems'
require 'appscript'
require 'base64'
require 'osax'

class P3Cpdf
    include Appscript
    
    def initialize(jobId,remoteDummyRootDir)
        @remoteDummyRootDir = Base64.decode64(remoteDummyRootDir)
    end
    
    def test
        P3libLogger::log('TYPO3 Dummy Root Dir:',@remoteDummyRootDir,'info')
        P3libLogger::log('Script Dir:',$0,'info')

        inFile = Base64.encode64(File.join(FileNewspaperAds_1v4_IND4rini.dirname($0),'../vendor/plugins/p3_cpdf/test/pitstop_server.pdf'))
        outFile = Base64.encode64("/tmp/pitstop_server.pdf")
        return certifyDocument(inFile,outFile,Base64.encode64("noQueue"),true)
    end
    
    def certifyDocument(pdfIn,pdfOut,pitstopQueue,fakeCertify=false)

		pdfIn  = Base64.decode64(pdfIn)
		pdfOut = Base64.decode64(pdfOut)
        
        if pdfIn.nil?
            P3libLogger::log("No input file to certitify",'','error')
            elsif not File.exist? pdfIn
            P3libLogger::log("Input file does not exist",pdfIn.to_s,'error')
			return 'not ok'
		end
        
		if pdfOut.nil?
            P3libLogger::log("No output file",pdfOut.to_s,'error')
			return 'not ok'
		end
        
        P3libLogger::log("Certitifying input file",pdfIn,'info')
        P3libLogger::log("Certitifying output file",pdfOut,'info')
        
        tmpName	= P3libUtil::helper_newtempname(9)+'.pdf'

        if fakeCertify
			FileUtils.cp(pdfIn, pdfOut) #fixme use tmp name
			return 'ok'
		end
        
        ## From here it's getting serious
        
        ## Choose remote of local Queue Folder
        if File.directory? '/Volumes/PitstopQueues'
            pitstopQueueFolder = File.join('/Volumes/PitstopQueues',Base64.decode64(pitstopQueue))
            elsif File.directory? '/PitstopQueues'
            pitstopQueueFolder = File.join('/PitstopQueues',Base64.decode64(pitstopQueue))
            else
            
            P3libLogger::log("PitstopQueues folder does not exist",'','error')
            return 'not ok'            
        end
        
        ## Check if folder do exist
        
        pitstopInputFolder = File.join(pitstopQueueFolder,'Input Folder')
		pitstopSuccesFolder = File.join(pitstopQueueFolder,'Processed Docs on Success')
		pitstopErrorFolder = File.join(pitstopQueueFolder,'Processed Docs on Error')
        
        if not File.directory? pitstopInputFolder 
            P3libLogger::log("Queue Input Folder does not exist",pitstopInputFolder,'error')
			return 'not ok'
        end
        
		FileUtils.cp(pdfIn,  File.join(pitstopInputFolder,tmpName)) #fixme use tmp name
        
		timeout=1 #timeout tien 5 minuten
		cResult = certifyResult(File.join(pitstopSuccesFolder,tmpName), File.join(pitstopErrorFolder,tmpName), timeout)
        
		until cResult == true
			sleep(1)
            P3libLogger::log("Waiting for instantpdf",'','info')
			
            timeout = timeout + 1
            P3libLogger::log("TimeOutPos",timeout.to_s,'info')
            
			cResult = certifyResult(File.join(pitstopSuccesFolder,tmpName), File.join(pitstopErrorFolder,tmpName), timeout)
		end
        
		if File.exist?(File.join(pitstopSuccesFolder,tmpName))
            P3libLogger::log("PitStop returned with succes",'','info')
			FileUtils.cp(File.join(pitstopSuccesFolder,tmpName), pdfOut)
            FileUtils.rm(File.join(pitstopSuccesFolder,tmpName))
			return 'ok'
            else
            P3libLogger::log("PitStop returned with failure",'','error')
			return false
		end
        
	end
    
    
	private
    
	def certifyResult(succesFile,errorFile,timeoutPos)
		if File.exist?(succesFile) or File.exist?(errorFile) or (timeoutPos == 300)
			return true
            else
			return false
		end
	end
    
end
