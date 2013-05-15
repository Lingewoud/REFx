require 'logger'

class  P3libLogger
	class << self
		def log(key, val='', type='info')
			if(@logger.nil?) then
				@logger 		= Logger.new("#{RAILS_ROOT}/log/pas3.log")
				@logger.level 	= Logger::DEBUG
			end

			case type
			when 'info'
				@logger.info Time.now.strftime("%b-%d-%Y %H:%M") +' INFO - '+ key+ ': '+ val
			when 'error'

				@logger.error Time.now.strftime("%b-%d-%Y %H:%M") +' ERROR - '+ key+ ': '+ val
                #self.mail('Error:'+key,Time.now.to_s+' - '+ key+ ': '+ val)

			when 'warn'
				@logger.warn Time.now.strftime("%b-%d-%Y %H:%M") +' WARNING - '+ key+ ': '+ val
			when 'fatal'
				@logger.fatal Time.now.strftime("%b-%d-%Y %H:%M") +' FATAL - '+ key+ ': '+ val
			when 'unknown'
				@logger.unknown Time.now.strftime("%b-%d-%Y %H:%M") +' UNKNOWN - '+ key+ ': '+ val
			when 'debug'
				@logger.debug Time.now.strftime("%b-%d-%Y %H:%M") +' DEBUG - '+ key+ ': '+ val
			end
		end
	end
end
