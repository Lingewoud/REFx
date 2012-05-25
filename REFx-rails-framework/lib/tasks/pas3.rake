#require 'fileutils'  
#require "yaml"
namespace :pas3  do

	desc "installsqlite"
	task :installsqlite => :environment do
		if File.file?("db/development.sqlite3")
			print "sqlite already exists. run Rake pas3:purgesqlite first\n"
		else
			p `pwd`
			filename = "config/database.yml"

			# Create a new file and write to it  
			File.open(filename, 'w') do |f2|  
				f2.puts "development:\n   adapter: sqlite3\n   database: db/development.sqlite3\n   pool: 5\n   timeout: 5000\n"  
			end

			Rake::Task['db:migrate'].invoke
			#Rake::Task['backgroundrb:create_queue'].invoke
		end
	end

	desc "purgesqlite"
	task :purgesqlite => :environment do
		FileUtils.rm_r "db/development.sqlite3", :force => true
	end
end
