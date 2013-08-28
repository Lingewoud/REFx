require 'logger'

class P3libLogger
    class << self
    
        # we use the types info, error, debug, warning
        def log(key, val='', type='info')
            
            if(@logger.nil?) then
                @logger 		= Logger.new("#{RAILS_ROOT}/log/pas3.log")
                @logger.level   = Logger::DEBUG
            end
            
            if(!$debug.nil? && type=='debug')
                logstring = "#{type.upcase} - #{key}#{val==''?'':': '+val}"
                @logger.info Time.now.strftime("%b-%d-%Y %H:%M") +' '+ logstring
            elsif(type!='debug')
                logstring = "#{type.upcase} - #{key}#{val==''?'':': '+val}"
                @logger.info Time.now.strftime("%b-%d-%Y %H:%M") +' '+ logstring
            end
        end
    end
end
