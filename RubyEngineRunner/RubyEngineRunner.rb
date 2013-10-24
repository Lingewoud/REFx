######!/usr/bin/env ruby
#
#  jobWrapper.rb
#  refxlooptests
#
#  Created by Pim Snel on 04-10-11.
#  Copyright 2011 Lingewoud B.V. All rights reserved.
#
#require "rubygems"

require 'optparse'
require 'fileutils'
require 'base64'
require 'pathname'

#require "bundler/setup"

#require 'active_record'

class RefxJobWrapper
    
    def selectJobById(jobId)
		pJob = Job.find(jobId)
		runJob(pJob)
	end
    
    def runJob(pJob)
        
        @logdir = File.expand_path('~')+"/Library/Logs/REFx4"
        Dir.mkdir(@logdir) unless File.exists?(@logdir)
        @logfile = @logdir + '/Engines.log'
        
		#p "start running job"
		pJob.attempt = pJob.attempt.to_i + 1

		## SAVE JOB: attempt + 1
		pJob.save

#		if pJob.attempt > pJob.max_attempt
#			p "max attempt reached"
#			pJob.status = 66
#		else
			#logger.info(Time.now.to_s+': start processing job '+ pJob.id.to_s)
			cmdbody = YAML::load(pJob.body)

			#We always add the jobId to the init arguments on the first position
			initArgString = "'"+pJob.id.to_s+"'"

			#IF THE PLUGIN NEEDS MORE ARGUMENTS
			initArgString2= createArgString(cmdbody['init_args'])

			initArgString = initArgString + ',' + initArgString2 if not initArgString.nil?

			methodArgString= createArgString(cmdbody['method_args'])

			##### CMDBODY DEBUG

			#logger.info 'engine: '+pJob.engine
			#logger.info 'method: '+cmdbody['method']
			#logger.info 'init_args: '+ initArgString
			#logger.info 'method_args: '+ methodArgString

			# CREATE ENGINE OBJECT and make sure the engine object is nil
			@engineObject=nil

            require "./#{pJob.engine}.rb"

			evalcmd1=pJob.engine+'.new('+initArgString+')'
			#p evalcmd1
			@engineObject = eval(evalcmd1)

#print "creating engine object"
			if @engineObject
				logStartNewJob

				evalcommand='@returnVal = @engineObject.'+cmdbody['method']+'('+methodArgString+')'

				@startTime = 'JOB STARTED  :  '+ Time.now.strftime("%b-%d-%Y %H:%M")
				_startTime = Time.now
				eval(evalcommand)
                
				@endTime = 'JOB FINISHED : '+ Time.now.strftime("%b-%d-%Y %H:%M")
				_endTime = Time.now
				@duration = 'JOB DURATION : '+ sprintf( "%0.02f", ((_endTime-_startTime)/60)) + "min."

#p 'call logJobSummary'
                logJobSummery

				pJob.status = 10
				pJob.returnbody = @returnVal
			else
				errorMsg = "engine "+pJob.engine+" does not exist"
				print "failed object can be made"
				pJob.returnbody = errorMsg
				pJob.status = 20
			end
		#end
		pJob.save
		#p "finished job"

	end

	def logStartNewJob

		open(@logfile, 'a') { |f|
            f.puts "\n"
			f.puts "------------ STARTING A NEW REFx JOB -------------\n"
			if($debug)
                f.puts "DEBUG IS SET ON\n"
			end
		}
	end
    
	def logJobSummery
        #p 'log summary'
        open(@logfile, 'a') { |f|
			f.puts "------------ FINISH REFx JOB ---------------------\n"
			f.puts @startTime +"\n"
			f.puts @endTime +"\n"
			f.puts @duration +"\n"
			f.puts "--------------------------------------------------\n"
		}
	end

	def createArgString(argArr)
		if not argArr.nil? and not argArr.empty?
			@initArgArr = Array.new
			argArr.each do |iArg|
				if iArg['type'] == "string"
					if(iArg['value'].class == Array)
						iArg['value'] = '[' + iArg['value'].to_s + ']'
					elsif(iArg['value'].nil?)
						iArg['value'] = ""
					else
						iArg['value'] = iArg['value'].delete("\n")
					end

					iArg['value']  = Base64.encode64(iArg['value'])

					@initArgArr<< "'"+ iArg['value'] +"'"
				else
					@initArgArr<< iArg['value']
				end
			end
			newString = @initArgArr.join(',')
			return newString
		end

		return ''
	end
    
    def insertTestJob(engineName,testindex,testSourceFilename)
        p 'INSERTING TEST JOB'
        
        testindex = 0 if testindex.nil?
        
        source_file_base_dir = File.expand_path('~')+'/Library/REFx4'
        enginePlistPath = File.expand_path('~')+"/Library/REFx4/Engines/#{engineName}.bundle/Contents/Info.plist"
        
        enginePlistDict = Plist::parse_xml(enginePlistPath)
   
        bodyYaml = enginePlistDict['testJobs'][testindex.to_i]['bodyYaml']
        


        newId = Job.find_by_sql('SELECT * FROM jobs ORDER BY id DESC')
        
        id = newId[0].id + 1
        id = 9999 if newId.nil?
        
        testJobPath = "TestJobs/"+id.to_s
        p testJobPath
        
       
        engineTestJobPath = File.expand_path('~')+"/Library/REFx4/Engines/#{engineName}.bundle/Contents/Resources/#{bodyYaml}"
        
        jobBody = File.read(engineTestJobPath)
        jobBody = jobBody.gsub("<%=JOB_PATH%>", testJobPath)
        jobBody = jobBody.gsub("<%=SOURCE_FILE_DIR%>", source_file_base_dir)

       if not testSourceFilename.nil?
           # make relative path from absolute
           path1 = Pathname.new source_file_base_dir
           path2 = Pathname.new testSourceFilename
           relative_testSourceFilename = path2.relative_path_from path1
           
           jobBody = jobBody.gsub("<%=SOURCE_FILE_NAME%>", relative_testSourceFilename)
        end
        
        pJob = Job.new
        
        pJob.priority = 1
        pJob.engine = engineName
        pJob.body = jobBody
        pJob.status = 1
        pJob.max_attempt = 1
        pJob.attempt = 0
        pJob.returnbody = ''
        
        pJob.save
    end
end

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.colorize_logging = false

ActiveRecord::Base.establish_connection(
	:adapter => "sqlite3",
	:dbfile  => File.expand_path('~')+"/Library/REFx4/Database/refx4production.sqlite3"
)

class Job < ActiveRecord::Base  
end  

$debug = false
options = {}

optparse = OptionParser.new do|opts|
	opts.banner = "Usage: refxJobWrapper.rb -j <JOBID>"

	options[:environment] = 'development'
	opts.on( '-l', '--environment environment', 'rails environment' ) do|environment|
		options[:environment] = environment
	end

	options[:jobid] = nil
	opts.on( '-j', '--jobid jobid', 'jobid' ) do|jobid|
		options[:jobid] = jobid
	end
    
	options[:test] = nil
	opts.on( '-t', '--test engineName', 'insert engine\'s test job' ) do |engineName|
		options[:test] = engineName
	end

    options[:testSourceFilename] = nil
    opts.on( '-f', '--filename testSourceFilename', 'sourceFile name for test job' ) do |testSourceFilename|
        options[:testSourceFilename] = testSourceFilename
    end

    options[:testindex] = '0'
    opts.on( '-i', '--testindex testindex', 'test index' ) do |testindex|
        p "option testindex"
        p testindex
        options[:testindex] = testindex
        options[:testindex].to_s
    end

    # This displays the help screen, all programs are
	# assumed to have this option.

	opts.on( '-d', '--debug', 'debug mode')  do
		$debug = true
		p "refxJobWrapper: debug on"
	end


	# This displays the help screen, all programs are
	# assumed to have this option.
	opts.on( '-h', '--help', 'Display this screen' ) do
		puts opts
		exit
	end
end

# Parse the command-line. Remember there are two forms
# of the parse method. The 'parse' method simply parses
# ARGV, while the 'parse!' method parses ARGV and removes
# any options found there, as well as any parameters for
# the options. What's left is the list of files to resize.
optparse.parse!

#puts "Being verbose" if options[:verbose]/
#puts "Logging to file #{options[:logfile]}" if options[:logfile]
#p options[:jobid]

if options[:test]
	refxjob = RefxJobWrapper.new
	refxjob.insertTestJob(options[:test],options[:testindex],options[:testSourceFilename])
elsif options[:jobid] != 0
	refxjob = RefxJobWrapper.new
	refxjob.selectJobById(options[:jobid])
end

exit 0

