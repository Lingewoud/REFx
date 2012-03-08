class RpcController < ApplicationController
	web_service_dispatching_mode :delegated

	web_service :jobs, JobService.new
	web_service :core, CoreService.new
end
