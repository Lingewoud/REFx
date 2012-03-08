class StructNewCoreArgs < ActionWebService::Struct
	member :engine,			:string
	member :body,			:text
	member :priority,		:integer
	member :max_attempt,	:integer
end

class CoreAPI < ActionWebService::API::Base
	inflect_names false
	api_method :get_repo_root, :expects => nil,  :returns => [:text]
end
