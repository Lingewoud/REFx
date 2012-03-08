class JobService < ActionWebService::Base
	require 'YAML'
	web_service_api JobAPI

	def list_jobs()
		Job.find(:all)
	end

	def new_job(jobArgs)
		job = Job.create(:engine => jobArgs[:engine], :max_attempt => jobArgs[:max_attempt], :priority => jobArgs[:priority], :body => jobArgs[:body], :status => 1)
		job.id
	end

	def job_status(job_id)
		# 1 new
		# 10 finished succes
		# 20 finished failure

		res = Job.find(job_id, :select => 'status')
		res.status
	end

	def job_resultdata(job_id)
		res = Job.find(job_id, :select => 'returnbody')
		res.returnbody
	end
end
