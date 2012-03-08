require 'fileutils'
require 'YAML'
class CoreService < ActionWebService::Base
	web_service_api CoreAPI

	PAS3_CONFIG = YAML::load(File.open("#{RAILS_ROOT}/config/pas3.yml"))

	def get_repo_root()
		PAS3_CONFIG["development"]["file_repository_root"]
	end
end
