require 'logger'
class  P3Indesign_logger
	class << self
		def log(key, val, type)
			if(@logger.nil?) then
				@logger 		= Logger.new("#{RAILS_ROOT}/log/pas3.log")
				@logger.level 	= Logger::DEBUG
			end

			case type
			when 'info'
				@logger.info Time.now.to_s+' - '+ key+ ': '+ val
			when 'error'
				@logger.error Time.now.to_s+' - '+ key+ ': '+ val
			when 'warn'
				@logger.warn Time.now.to_s+' - '+ key+ ': '+ val
			when 'fatal'
				@logger.fatal Time.now.to_s+' - '+ key+ ': '+ val
			when 'unknown'
				@logger.unknown Time.now.to_s+' - '+ key+ ': '+ val
			when 'debug'
				@logger.debug Time.now.to_s+' - '+ key+ ': '+ val
			end
		end
	end
end
