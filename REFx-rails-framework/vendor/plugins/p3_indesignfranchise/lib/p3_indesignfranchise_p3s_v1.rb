class P3Indesignfranchise_p3s_v1

	def initialize(p3s_string)
		@log	= ''
		@logger = P3Indesignfranchise_logger.new()
		@p3l	= initLang	
		@p3s    = initScriptArray(p3s_string)
	end

	public

	def parseP3S(objectPath, type)
		ret_hash =	Hash.new

		if(@p3s.has_key?(":"+objectPath))
			@p3s[":"+objectPath].each do |el|
				v = checkValid(el, type)
				if(v)
					ret_hash[eval(":p3s_" + el[:attribute])] = v
				end
			end
		end
		return ret_hash
	end

	def returnLog
		return @log
	end

	private

	def log(key,val, type = 'info')
		(class << P3Indesignfranchise_logger; P3Indesignfranchise_logger; end).log(key, val, type)
		@log += type + ": " + key + " " + val + "\n"
	end

	def initLang
		p3s_lang = P3Indesignfranchise_p3s_v1_lang.new
		return p3s_lang.initiateLang
	end

	def initScriptArray(p3s_string)
		script_arr = Hash.new{|hash, key| hash[key] = Array.new}

		cleanUp(p3s_string)

		p3s_string.split(/\r/).each do |line|
			parsed = parseLine(line)
			if(parsed.class == Hash)
				script_arr[":"+parsed[:field]] << parsed
			end
		end
 
		return script_arr
	end

	def cleanUp(string)
		string = stripComments(string)
		string = stripSpaces(string)

		return string
	end

	def stripComments(string)
		@p3l[:commentblocks].each do |block|
			starting 	= Regexp.escape(block[1][:start])
			ending		= Regexp.escape(block[1][:end])
			while(string.match(/#{starting}.*?#{ending}/))
				string.slice!(/#{starting}.*?#{ending}/)
			end
		end

		return string
	end

	def stripSpaces(string)
		return string.gsub(/[ ]/, '')
	end

	def stripQuotes(string)

		string.gsub!("\342\200\230", '"')
		string.gsub!("\342\200\231", '"')
		string.gsub!("\342\200\234", '"')
		string.gsub!("\342\200\235", '"')
		return string.gsub!("\"", '')
	end

	def parseLine(line)
		line_hash = Hash.new

		operator = getOperator(line)
		if(operator)
			split_arr = line.split("#{operator}")
			line_hash[:operator] = operator	
			if(countPoints(split_arr[0], line))
				left_arr 				= split_arr[0].split('.')
				line_hash[:field] 		= left_arr[0]
				line_hash[:attribute] 	= left_arr[1]
				line_hash[:value]		= split_arr[1]
				line_hash[:line]		= line

				return line_hash
			end
		end
	end

	def getOperator(line)
		@p3l[:operators].each do |op|
			if (line.match("#{op}"))
				return op
			else
				if(!line.empty? && line.length > 1) then
					log('Syntax error: No valid operator found: ', line, 'error')
				end
				return false
			end
		end
	end

	def countPoints(string, line)
		num = string.scan(/\./).length

		if(num == 1)
			return true
		elsif(num == 0)
			log('Syntax error: The left hand side of the assignment requires an object and an attribute: ', line, 'error')
		elsif(num > 1)
			log('Syntax error: The left hand side of the assignment can only exist of one object and one attribute: ', line, 'error')
		end
	end

	def checkValid(el, type)
		oType		= checkTypeValid(type, el[:line])
		attribute	= (oType) ? checkAttributeValid(el[:attribute], type, el[:line]) : false
		operator	= (attribute) ? checkOperatorValid(el[:operator], el[:attribute], type, el[:line]) : false
		value		= (operator) ? checkValueValid(el[:value], el[:attribute], type, el[:line]) : false

		return value
	end

	def checkTypeValid(type, line)
		if(@p3l[:DOM].has_key?(eval(":"+type)))
			return type
		else
			log('Syntax error: No valid attributes found for object \''+type+'\':', line, 'error')
			return false
		end
	end

	def checkAttributeValid(att, type, line)
		if(@p3l[:DOM][eval(":"+type)][:attributes].has_key?(eval(":"+att.downcase)))
			return true
		else
			log('Syntax error: \''+att+'\' is not a valid attribute for object \''+type+'\':', line, 'error')
			return false
		end
	end

	def checkOperatorValid(op, att, type, line)
		if(@p3l[:DOM][eval(":"+type)][:attributes][eval(":"+att)][:operators].rindex(op) != nil)
			return true
		else
			log('Syntax error: \''+op+'\' is not a valid operator for attribute \''+att+'\' of object \''+type+'\':', line, 'error')
			return false
		end
	end

	def checkValueValid(val, att, type, line)
		types 	= ''
		p3_att 	= @p3l[:DOM][eval(":"+type)][:attributes][eval(":"+att)]
		m 		= false

		p3_att[:datatypes].each do |dt|
			types 	+= '\''+dt+'\', '
			data 	= checkDataType(val, dt)
			if(data)
				if(data.class == p3_att[:allowed].class || (p3_att[:allowed].class == String && p3_att[:allowed].to_s.downcase == data.to_s.downcase) || p3_att[:allowed] == "" || (p3_att[:allowed].class == Array && p3_att[:allowed].length == 0))
					return data
				elsif(p3_att[:allowed].class == Array)
					p3_att[:allowed].each do |all|
						m = (all.to_s.downcase == data.to_s.downcase || m == true) ? true : false
					end
					if(m)
						return data
					else
						log('Syntax error: Value \''+val+'\' does not match any of the allowed values ('+p3_att[:allowed].to_s+') for attribute \''+att+'\' of object \''+type+'\':', line, 'error')
						return false
					end
				else
					log('Warning:  Check for allowed values failed:', line, 'info')
					return data
				end
			end
		end	
		log('Syntax error: Datatype of \''+val+'\' does not match any valid datatype ('+types.to_s[0..-3]+') for attribute \''+att+'\' of object \''+type+'\':', line, 'error')
		return false
	end

	def checkDataType(data, dataType)
		case dataType
		when "string"
			return checkString(data)
		when "number"
			return checkNumber(data)
		when "float"
			return checkFloat(data)
		when "boolean"
			return checkBoolean(data)
		when "t3path"
			return checkT3Path(data)
		when "p3path"
			return checkP3Path(data)
		when "array"
			return checkArray(data)
		end
	end

	def checkString(data)
		data = stripSpaces(data)
		data = stripQuotes(data)
		return data
	end

	def checkNumber(data)
		data = stripSpaces(data)
		if(data.match(/^[-]?[0-9]*/))
			return data.to_i
		else
			return false
		end
	end

	def checkFloat(data)
		data = stripSpaces(data)
		if(data.match(/^[-]?[0-9]*?[.]?[0-9]*/))
			return data.to_f
		else
			return false
		end
	end

	def checkBoolean(data)
		data = stripSpaces(data)
		if(data == "false" || data == "true")
			return data
		 else
			return false
		 end
	end

	def checkT3Path(data)
		data = stripSpaces(data)
		if(data.scan(/\./).length == 3)
			data_arr = data.split('.')

			clss = id = attr = false

			@p3l[:T3S][:classes].each do |cls|
				clss = (clss == false && cls == data_arr[0]) ?  true : clss
			end

			@p3l[:T3S][:relative].each do |rlt|
				id = (id == false && (rlt == data_arr[1] || checkNumber(data_arr[1]))) ? true : id 
			end

			@p3l[:T3S][:attributes].each do |att|
				attr  = (attr == false && att == data_arr[3]) ? true : attr
			end

			if(clss && id  && attr)
				return data
			else
				return false
			end
		else
			return false
		end
	end

	def checkP3Path(data)
		data = stripSpaces(data)
		if(data.scan(/\./).length == 1)
			data_arr = data.split('.')
			
		if(@p3l[:attributes].include?(data_arr[1]))
				return data
			else
				return false
			end
		else
			return false
		end
	end

	def checkArray(data)
		data = stripSpaces(data)
		data = stripQuotes(data)
		
		if(checkArrayBrackets(data) && data.match(/^[\[].*[\]]$/))
			return rebuildArray(data)
		else
			return false
		end
	end

	def checkArrayBrackets(data)
		if(data.scan(/\[/).length == data.scan(/\]/).length)
		   	return true
		else
			return false
		end
	end

	def rebuildArray(data)
		data 		= data.to_s[1..-2]
		_ret 		= Array.new
		sub			= false

		data.split(',').each do |chnk|
			chnk = (sub) ? sub + "," + chnk : chnk
			if(checkArrayBrackets(chnk))
				if(chnk.match(/^[\[].*[\]]$/))
					_ret << rebuildArray(chnk)
				else
					_ret << chnk
				end
				sub = false
			else
				sub = chnk
			end
		end

		return _ret
	end
end 
