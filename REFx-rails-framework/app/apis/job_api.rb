class StructNewJobArgs < ActionWebService::Struct
	member :engine,			:string
	member :body,			:text
	member :priority,		:integer
	member :max_attempt,	:integer
end

class JobAPI < ActionWebService::API::Base
	inflect_names false
	api_method :list_jobs, :expects => nil, :returns => [[Job]]
	api_method :flush_jobs, :expects => nil, :returns => [[Job]]
	api_method :new_job, :expects => [StructNewJobArgs], :returns => [:integer]
	api_method :job_status, :expects => [:integer], :returns => [:integer]
	api_method :job_rerun, :expects => [:integer], :returns => [:integer]
    api_method :job_resultdata, :expects => [:integer], :returns => [:text]
end
