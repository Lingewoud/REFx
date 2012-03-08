class P3s_v1_lang_writeout

	def initialize()
		@log	= ''
		@logger = P3Indesignfranchise_logger.new()
		@p3l	= initLang	
		@wiki   = ''
	end

	public

	def writeout
		wiki('')
		wiki('h1. P3S language')
		wiki('')
		@p3l.each do |le|
			if(le.class == Array)
				wiki('')
				wiki('> h2. ' + le[0].to_s[0..-1].capitalize)
				wiki('')
				case  le[0].to_s[0..-1].capitalize
					when "Operators"
						formatOperators(le[1])
					when  "Dom"
						formatDom(le[1])	
					when "T3s"
						formatT3s(le[1])
					when "Attributes"
						formatAttributes(le[1])
					when "Commentblocks"
						formatCommentblocks(le[1])
				end
			end	
		end

		return @wiki
	end

	private

	def log(key,val, type = 'info')
		(class << P3Indesignfranchise_logger; P3Indesignfranchise_logger; end).log(key, val, type)
		@log += type + ": " + key + " " + val + "\n"
	end

	def wiki(string)
		@wiki += string+"\n"
	end

	def initLang
		p3s_lang = P3Indesignfranchise_p3s_v1_lang.new
		return p3s_lang.initiateLang
	end

	def formatOperators(object)
		object.each do |op|
			wiki('>* ' + op)
		end
	end

	def formatDom(object)
		object.each do |dt|
			wiki('')
			wiki('> h3. ' + dt[0].to_s.capitalize)
			wiki('')
			wiki('>> h4. attributes')
			wiki('')
			dt[1][:attributes].each do |att|
				wiki('')
				wiki('>> *' + att[0].to_s.capitalize+'*')
				wiki('>>>> @allowed operators@')
				wiki('>>>>> '+att[1][:operators].to_s)
				wiki('')
				wiki('>>>> @allowed datatypes@')
				wiki('>>>>> '+att[1][:datatypes].to_s)
				wiki('')
				wiki('>>>> @default value@')
				wiki('>>>>> '+att[1][:default].to_s)
				wiki('')
				wiki('>>>> @info@')
				wiki('>>>>> '+att[1][:infotext])
				wiki('')
				wiki('>>>> @example@')
				wiki('>>>>> <pre>'+att[1][:example]+'</pre>')
			end
		end	
	end

	def formatT3s(object)
		object.each do |t3s|
			wiki('> h3. '+ t3s[0].to_s[0..-1].capitalize)
			t3s[1].each do |obj|
				wiki('>>* '+obj)
			end
		end
	end

	def formatAttributes(object)
		object.each do |att|
			wiki('>>* ' + att)
		end
	end

	def formatCommentblocks(object)
		wiki('>>h3. Single comments')
		object.each do |cb|
			if(cb[0].to_s.index('single'))
				wiki('>>* @'+cb[1][:start]+' comment text@')
			end
		end
		wiki('')
		wiki('>>h3. Multiline comments')
		object.each do |cb|
			if(cb[0].to_s.index('multi'))
				wiki('>>* @'+cb[1][:start]+'@')
				wiki('@ comment text@')
				wiki('@'+cb[1][:end]+'@')
			end
		end
	end
end

