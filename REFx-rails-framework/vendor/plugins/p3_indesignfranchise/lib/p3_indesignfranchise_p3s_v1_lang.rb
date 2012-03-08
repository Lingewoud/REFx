class P3Indesignfranchise_p3s_v1_lang
	public

	def initiateLang
		lang_arr = Hash.new
		lang_arr[:DOM] = Hash.new

		lang_arr[:DOM][:document] = Hash.new
		lang_arr[:DOM][:document][:attributes] = Hash.new

		lang_arr[:DOM][:document][:attributes][:use] = Hash.new
		lang_arr[:DOM][:document][:attributes][:use][:operators] 				= ["="]
		lang_arr[:DOM][:document][:attributes][:use][:datatypes] 				= ["string"]
		lang_arr[:DOM][:document][:attributes][:use][:allowed]		 			= ["FE", "BE"]
		lang_arr[:DOM][:document][:attributes][:use][:default]		 			= "FE"
		lang_arr[:DOM][:document][:attributes][:use][:infotext]		 			= "Defines whether the fields in this document should be parsed at the frontend (FE) or the backend (BE)"
		lang_arr[:DOM][:document][:attributes][:use][:example]		 			= "document.use = \"FE\""

		lang_arr[:DOM][:spread] = Hash.new
		lang_arr[:DOM][:spread][:attributes] = Hash.new		
	
		lang_arr[:DOM][:spread][:attributes][:position] = Hash.new
		lang_arr[:DOM][:spread][:attributes][:position][:operators]				= ["="]
		lang_arr[:DOM][:spread][:attributes][:position][:datatypes] 			= ["number"]
		lang_arr[:DOM][:spread][:attributes][:position][:allowed]	 			= Array.new
		lang_arr[:DOM][:spread][:attributes][:position][:default]	 			= ""
		lang_arr[:DOM][:spread][:attributes][:position][:infotext]	 			= "Number to determine the position of the spread within de document.\r"
		lang_arr[:DOM][:spread][:attributes][:position][:infotext]	 			+= "The first spread position is indicated by 1, the last spread by 0. \r"
		lang_arr[:DOM][:spread][:attributes][:position][:infotext]	 			+= "Negative values indicate the position relative to the last spread of the document."
		lang_arr[:DOM][:spread][:attributes][:position][:example]	 			= "spread[6].position = -1"

		lang_arr[:DOM][:spread][:attributes][:minuse] = Hash.new
		lang_arr[:DOM][:spread][:attributes][:minuse][:operators] 				= ["="]
		lang_arr[:DOM][:spread][:attributes][:minuse][:datatypes] 				= ["number"]
		lang_arr[:DOM][:spread][:attributes][:minuse][:allowed]		 			= Array.new
		lang_arr[:DOM][:spread][:attributes][:minuse][:default]		 			= 0
		lang_arr[:DOM][:spread][:attributes][:minuse][:infotext]		 		= "Indicates how many times the spread should be used at least within the document"
		lang_arr[:DOM][:spread][:attributes][:minuse][:example]		 			= "spread[2].minuse = 1"

		lang_arr[:DOM][:spread][:attributes][:maxuse] = Hash.new
		lang_arr[:DOM][:spread][:attributes][:maxuse][:operators] 				= ["="]
		lang_arr[:DOM][:spread][:attributes][:maxuse][:datatypes] 				= ["number"]
		lang_arr[:DOM][:spread][:attributes][:maxuse][:allowed]		 			= Array.new
		lang_arr[:DOM][:spread][:attributes][:maxuse][:default]		 			= ""
		lang_arr[:DOM][:spread][:attributes][:maxuse][:infotext]		 		= "Indicates how many times the spread can be used within the document."
		lang_arr[:DOM][:spread][:attributes][:maxuse][:example]		 			= "spread[7].maxuse = 1"

		lang_arr[:DOM][:spread][:attributes][:keeptogether] = Hash.new
		lang_arr[:DOM][:spread][:attributes][:keeptogether][:operators] 		= ["="]
		lang_arr[:DOM][:spread][:attributes][:keeptogether][:datatypes] 		= ["boolean"]
		lang_arr[:DOM][:spread][:attributes][:keeptogether][:allowed] 			= [true, false]
		lang_arr[:DOM][:spread][:attributes][:keeptogether][:default]	 		= false
		lang_arr[:DOM][:spread][:attributes][:keeptogether][:infotext]	 		= "Indicates whether the pages of the spread should be kept together or can be placed independently" 
		lang_arr[:DOM][:spread][:attributes][:keeptogether][:example] 			= "spread[2].keeptogether = true"
		
		lang_arr[:DOM][:spread][:attributes][:ignore] = Hash.new
		lang_arr[:DOM][:spread][:attributes][:ignore][:operators] 	 			= ["="]
		lang_arr[:DOM][:spread][:attributes][:ignore][:datatypes] 				= ["boolean"]
		lang_arr[:DOM][:spread][:attributes][:ignore][:allowed]					= [true, false]
		lang_arr[:DOM][:spread][:attributes][:ignore][:default]					= false
		lang_arr[:DOM][:spread][:attributes][:ignore][:infotext]				= "Hides a spread for users so the spread (and it's contents) cannot be chosen as template."
		lang_arr[:DOM][:spread][:attributes][:ignore][:example]		 			= "spread[4].ignore = true"

		lang_arr[:DOM][:spread][:attributes][:use] = Hash.new
		lang_arr[:DOM][:spread][:attributes][:use][:operators]	 				= ["="]
		lang_arr[:DOM][:spread][:attributes][:use][:datatypes] 					= ["string"]
		lang_arr[:DOM][:spread][:attributes][:use][:allowed]		 			= ["FE", "BE"]
		lang_arr[:DOM][:spread][:attributes][:use][:default]		 			= ""
		lang_arr[:DOM][:spread][:attributes][:use][:infotext]		 			= "Defines whether the fields on this spread should be parsed at the frontend (FE) or the backend (BE)"
		lang_arr[:DOM][:spread][:attributes][:use][:example]		 			= "spread[1].use = \"FE\""

		lang_arr[:DOM][:page] = Hash.new
		lang_arr[:DOM][:page][:attributes] = Hash.new

		#lang_arr[:DOM][:page][:attributes][:position] = Hash.new
		#lang_arr[:DOM][:page][:attributes][:position][:operators] 	 			= ["="]
		#lang_arr[:DOM][:page][:attributes][:position][:datatypes] 				= ["number"]
		#lang_arr[:DOM][:page][:attributes][:position][:allowed]	 				= Array.new
		#lang_arr[:DOM][:page][:attributes][:position][:default]	 				= ""
		#lang_arr[:DOM][:page][:attributes][:position][:infotext]	 			= "Number to determine the position of the page within de document.\r"
		#lang_arr[:DOM][:page][:attributes][:position][:infotext]	 			+= "The first page position is indicated by 1, the last page by 0. \r"
		#lang_arr[:DOM][:page][:attributes][:position][:infotext]	 			+= "Negative values indicate the position relative to the last page of the document."
		#lang_arr[:DOM][:page][:attributes][:position][:example]	 				= "page[5].position = -1"

		lang_arr[:DOM][:page][:attributes][:minuse] = Hash.new
		lang_arr[:DOM][:page][:attributes][:minuse][:operators] 	 			= ["="]
		lang_arr[:DOM][:page][:attributes][:minuse][:datatypes] 				= ["number"]
		lang_arr[:DOM][:page][:attributes][:minuse][:allowed]		 			= Array.new
		lang_arr[:DOM][:page][:attributes][:minuse][:default]		 			= 0
		lang_arr[:DOM][:page][:attributes][:minuse][:infotext]			 		= "Indicates how many times the page should be used at least within the document"
		lang_arr[:DOM][:page][:attributes][:minuse][:example]		 			= "page[2].minuse = 1"

		lang_arr[:DOM][:page][:attributes][:maxuse] = Hash.new
		lang_arr[:DOM][:page][:attributes][:maxuse][:operators] 	 			= ["="]
		lang_arr[:DOM][:page][:attributes][:maxuse][:datatypes] 				= ["number"]
		lang_arr[:DOM][:page][:attributes][:maxuse][:allowed]		 			= Array.new
		lang_arr[:DOM][:page][:attributes][:maxuse][:default]		 			= ""
		lang_arr[:DOM][:page][:attributes][:maxuse][:infotext]			 		= "Indicates how many times the page can be used within the document."
		lang_arr[:DOM][:page][:attributes][:maxuse][:example]		 			= "page[7].maxuse = 1"

		lang_arr[:DOM][:page][:attributes][:side] = Hash.new
		lang_arr[:DOM][:page][:attributes][:side][:operators] 	 				= ["="]
		lang_arr[:DOM][:page][:attributes][:side][:datatypes] 					= ["string"]
		lang_arr[:DOM][:page][:attributes][:side][:allowed]			 			= ["left", "right"]
		lang_arr[:DOM][:page][:attributes][:side][:default]			 			= ""
		lang_arr[:DOM][:page][:attributes][:side][:infotext]			 		= "Restricts the placement of a page to either the right or the left-hand side of a spread"
		lang_arr[:DOM][:page][:attributes][:side][:example]		 				= "page[2].side = \"left\""

		lang_arr[:DOM][:page][:attributes][:ignore] = Hash.new
		lang_arr[:DOM][:page][:attributes][:ignore][:operators] 	 			= ["="]
		lang_arr[:DOM][:page][:attributes][:ignore][:datatypes] 				= ["boolean"]
		lang_arr[:DOM][:page][:attributes][:ignore][:allowed]					= [true, false]
		lang_arr[:DOM][:page][:attributes][:ignore][:default]					= false
		lang_arr[:DOM][:page][:attributes][:ignore][:infotext]					= "Hides a spreadd for users so the page cannot be chosen as template."
		lang_arr[:DOM][:page][:attributes][:ignore][:example]		 			= "page[4].ignore = true"

		lang_arr[:DOM][:page][:attributes][:replaceable] = Hash.new
		lang_arr[:DOM][:page][:attributes][:replaceable][:operators] 	 		= ["="]
		lang_arr[:DOM][:page][:attributes][:replaceable][:datatypes] 	 		= ["boolean"]
		lang_arr[:DOM][:page][:attributes][:replaceable][:allowed]		 		= [true, false]
		lang_arr[:DOM][:page][:attributes][:replaceable][:default]		 		= true
		lang_arr[:DOM][:page][:attributes][:replaceable][:infotext]		 		= "Indicates wheter a page can be replaced at it's position"
		lang_arr[:DOM][:page][:attributes][:replaceable][:example]		 		= "page[4].replaceable = false"

		lang_arr[:DOM][:page][:attributes][:order] = Hash.new
		lang_arr[:DOM][:page][:attributes][:order][:operators] 		 			= ["="]
		lang_arr[:DOM][:page][:attributes][:order][:datatypes] 					= ["array"]
		lang_arr[:DOM][:page][:attributes][:order][:allowed]					= ""
		lang_arr[:DOM][:page][:attributes][:order][:default]					= ""
		lang_arr[:DOM][:page][:attributes][:order][:infotext]					= "Defines in what order user input fields are offered to users.\r"
		lang_arr[:DOM][:page][:attributes][:order][:infotext]					+= "The first element of the array is the first to be presented to the user."
		lang_arr[:DOM][:page][:attributes][:order][:example]		 			= "page[3].order = [ga_textInput_name, ga_textInput_address, ga_textInput_phonenumber]"

		lang_arr[:DOM][:page][:attributes][:groups] = Hash.new
		lang_arr[:DOM][:page][:attributes][:groups][:operators] 	 			= ["="]
		lang_arr[:DOM][:page][:attributes][:groups][:datatypes] 				= ["array"]
		lang_arr[:DOM][:page][:attributes][:groups][:allowed]					= ""
		lang_arr[:DOM][:page][:attributes][:groups][:default]					= ""
		lang_arr[:DOM][:page][:attributes][:groups][:infotext]					= "Groups the specified fields. Grouped input fields will be presented to the user as one step.\r"
		lang_arr[:DOM][:page][:attributes][:groups][:infotext]					+= "Grouped fields can also be used in stacks."
		lang_arr[:DOM][:page][:attributes][:groups][:example]		 			= "page[2].groups = [[\"userinfo\",[ga_textInput_name, ga_textInput_age, ga_textInput_gender]], [\"address\", [ga_txtInput_address, ga_textInput_city, ga_textInput_zip]]]"

		lang_arr[:DOM][:page][:attributes][:stacks] = Hash.new
		lang_arr[:DOM][:page][:attributes][:stacks][:operators] 	 			= ["="]
		lang_arr[:DOM][:page][:attributes][:stacks][:datatypes] 				= ["array"]
		lang_arr[:DOM][:page][:attributes][:stacks][:allowed]					= ""
		lang_arr[:DOM][:page][:attributes][:stacks][:default]					= ""
		lang_arr[:DOM][:page][:attributes][:stacks][:infotext]					= "Stacks are repetative page elements which consists of a field or group and can be asssigned to a collection of data.\r"
		lang_arr[:DOM][:page][:attributes][:stacks][:infotext]					+= "The field or group it consists of will now be repeatedly placed in the document with the content replaced with content from each member of the data collection."
		lang_arr[:DOM][:page][:attributes][:stacks][:example]		 			= "page[2].groups = [[\"userstack\",pp_mergeTextField_name], [\"namestack\", usergroup]"

		lang_arr[:DOM][:page][:attributes][:use] = Hash.new
		lang_arr[:DOM][:page][:attributes][:use][:operators]	 				= ["="]
		lang_arr[:DOM][:page][:attributes][:use][:datatypes] 					= ["string"]
		lang_arr[:DOM][:page][:attributes][:use][:allowed]			 			= ["FE", "BE"]
		lang_arr[:DOM][:page][:attributes][:use][:default]			 			= ""
		lang_arr[:DOM][:page][:attributes][:use][:infotext]		 				= "Defines whether the fields on this page should be parsed at the frontend (FE) or the backend (BE)"
		lang_arr[:DOM][:page][:attributes][:use][:example]		 				= "page[3].use = \"FE\""

		lang_arr[:DOM][:text] = Hash.new
		lang_arr[:DOM][:text][:attributes] = Hash.new

		lang_arr[:DOM][:text][:attributes][:label] = Hash.new
		lang_arr[:DOM][:text][:attributes][:label][:operators] 					= ["="]
		lang_arr[:DOM][:text][:attributes][:label][:datatypes] 					= ["string"]
		lang_arr[:DOM][:text][:attributes][:label][:allowed]					= ""
		lang_arr[:DOM][:text][:attributes][:label][:default]					= ""
		lang_arr[:DOM][:text][:attributes][:label][:infotext]					= "The label the textinput will be provided with when presented to the user"
		lang_arr[:DOM][:text][:attributes][:label][:example]					= "text_lastname.label = \"Last Name:\""

		lang_arr[:DOM][:text][:attributes][:extended_info] = Hash.new
		lang_arr[:DOM][:text][:attributes][:extended_info][:operators] 			= ["="]
		lang_arr[:DOM][:text][:attributes][:extended_info][:datatypes] 			= ["string"]
		lang_arr[:DOM][:text][:attributes][:extended_info][:allowed]			= ""
		lang_arr[:DOM][:text][:attributes][:extended_info][:default]			= ""
		lang_arr[:DOM][:text][:attributes][:extended_info][:infotext]			= "An additional text that can be shown to the user, for instance as help text"
		lang_arr[:DOM][:text][:attributes][:extended_info][:example]			= "text_phonenumber.extended_info = \"Enter your phonenumber including your country code\""

		lang_arr[:DOM][:text][:attributes][:value] = Hash.new
		lang_arr[:DOM][:text][:attributes][:value][:operators]			 		= ["="]
		lang_arr[:DOM][:text][:attributes][:value][:datatypes] 					= ["string","t3path", "p3path"]
		lang_arr[:DOM][:text][:attributes][:value][:allowed]					= ""
		lang_arr[:DOM][:text][:attributes][:value][:default]					= ""
		lang_arr[:DOM][:text][:attributes][:value][:infotext]					= "Tells the system the right hand side of the assignment contains a value the contents of the text should be replaced with"
		lang_arr[:DOM][:text][:attributes][:value][:example]					= "text_phonenumber.value = \"Hello World!\""

		lang_arr[:DOM][:text][:attributes][:rich] = Hash.new
		lang_arr[:DOM][:text][:attributes][:rich][:operators]					= ["="]
		lang_arr[:DOM][:text][:attributes][:rich][:datatypes] 					= ["boolean"]
		lang_arr[:DOM][:text][:attributes][:rich][:allowed]						= [true, false]
		lang_arr[:DOM][:text][:attributes][:rich][:default]						= false
		lang_arr[:DOM][:text][:attributes][:rich][:infotext]					= "Indicates whether the textfield when presented to the user should be rendered as rich textfield (HTML enabled) or not "
		lang_arr[:DOM][:text][:attributes][:rich][:example]						= "text_richtextfield.rich = true"

		lang_arr[:DOM][:text][:attributes][:style] = Hash.new
		lang_arr[:DOM][:text][:attributes][:style][:operators]			 		= ["="]
		lang_arr[:DOM][:text][:attributes][:style][:datatypes] 					= ["p3path"]
		lang_arr[:DOM][:text][:attributes][:style][:allowed]					= ""
		lang_arr[:DOM][:text][:attributes][:style][:default]					= ""
		lang_arr[:DOM][:text][:attributes][:style][:infotext]					= "Attribute for copying textfield styles"
		lang_arr[:DOM][:text][:attributes][:style][:example]					= "text_body.h1 = text_h1.style"

		lang_arr[:DOM][:text][:attributes][:h1] = Hash.new
		lang_arr[:DOM][:text][:attributes][:h1][:operators]						= ["="]
		lang_arr[:DOM][:text][:attributes][:h1][:datatypes] 					= ["p3path"]
		lang_arr[:DOM][:text][:attributes][:h1][:allowed]						= ""
		lang_arr[:DOM][:text][:attributes][:h1][:default]						= ""
		lang_arr[:DOM][:text][:attributes][:h1][:infotext]						= "Attribute for mapping a HTML style to the style of the specified element in Indesign"
		lang_arr[:DOM][:text][:attributes][:h1][:example]						= "text_richtextfield.h1 = text_capitalboldstyle"

		lang_arr[:DOM][:text][:attributes][:h2] = Hash.new
		lang_arr[:DOM][:text][:attributes][:h2][:operators]						= ["="]
		lang_arr[:DOM][:text][:attributes][:h2][:datatypes] 					= ["p3path"]
		lang_arr[:DOM][:text][:attributes][:h2][:allowed]						= ""
		lang_arr[:DOM][:text][:attributes][:h2][:default]						= ""
		lang_arr[:DOM][:text][:attributes][:h2][:infotext]						= "Attribute for mapping a HTML style to the style of the specified element in Indesign"
		lang_arr[:DOM][:text][:attributes][:h2][:example]						= "text_richtextfield.h2 = text_capitalboldstyle"

		lang_arr[:DOM][:text][:attributes][:h3] = Hash.new
		lang_arr[:DOM][:text][:attributes][:h3][:operators]						= ["="]
		lang_arr[:DOM][:text][:attributes][:h3][:datatypes] 					= ["p3path"]
		lang_arr[:DOM][:text][:attributes][:h3][:allowed]						= ""
		lang_arr[:DOM][:text][:attributes][:h3][:default]						= ""
		lang_arr[:DOM][:text][:attributes][:h3][:infotext]						= "Attribute for mapping a HTML style to the style of the specified element in Indesign"
		lang_arr[:DOM][:text][:attributes][:h3][:example]						= "text_richtextfield.h3 = text_capitalboldstyle"

		lang_arr[:DOM][:text][:attributes][:overflow] = Hash.new
		lang_arr[:DOM][:text][:attributes][:overflow][:operators]	 			= ["="]
		lang_arr[:DOM][:text][:attributes][:overflow][:datatypes] 				= ["string"]
		lang_arr[:DOM][:text][:attributes][:overflow][:allowed]			 		= ["scale", "hide"]
		lang_arr[:DOM][:text][:attributes][:overflow][:default]			 		= "scale"
		lang_arr[:DOM][:text][:attributes][:overflow][:infotext]		 		= "Defines what happpens when text overflows the textfield. 'Scale' scales back the pointsize, 'hide' hides the overflowing text. "
		lang_arr[:DOM][:text][:attributes][:overflow][:example]		 			= "text_longtext.overflow = \"hide\""

		lang_arr[:DOM][:text][:attributes][:use] = Hash.new
		lang_arr[:DOM][:text][:attributes][:use][:operators]	 				= ["="]
		lang_arr[:DOM][:text][:attributes][:use][:datatypes] 					= ["string"]
		lang_arr[:DOM][:text][:attributes][:use][:allowed]			 			= ["FE", "BE"]
		lang_arr[:DOM][:text][:attributes][:use][:default]			 			= ""
		lang_arr[:DOM][:text][:attributes][:use][:infotext]		 				= "Defines whether the textfield should be parsed at the frontend (FE) or the backend (BE)"
		lang_arr[:DOM][:text][:attributes][:use][:example]		 				= "text_userinput.use = \"FE\""

		lang_arr[:DOM][:text][:attributes][:visible] = Hash.new
		lang_arr[:DOM][:text][:attributes][:visible][:operators]	 			= ["="]
		lang_arr[:DOM][:text][:attributes][:visible][:datatypes]	 			= ["boolean", "t3path"] 
		lang_arr[:DOM][:text][:attributes][:visible][:allowed]			 		= ""
		lang_arr[:DOM][:text][:attributes][:visible][:default]		 			= true
		lang_arr[:DOM][:text][:attributes][:visible][:infotext]		 			= "Makes it possible to make an object invisible"
		lang_arr[:DOM][:text][:attributes][:visible][:example]	 				= "text_mytext.visible = false"

		lang_arr[:DOM][:image] = Hash.new
		lang_arr[:DOM][:image][:attributes] = Hash.new

		lang_arr[:DOM][:image][:attributes][:label] = Hash.new
		lang_arr[:DOM][:image][:attributes][:label][:operators] 				= ["="]
		lang_arr[:DOM][:image][:attributes][:label][:datatypes] 				= ["string"]
		lang_arr[:DOM][:image][:attributes][:label][:allowed]		 			= ""
		lang_arr[:DOM][:image][:attributes][:label][:default]		 			= ""
		lang_arr[:DOM][:image][:attributes][:label][:infotext]		 			= "The label the imageinput will be provided with when presented to the user"
		lang_arr[:DOM][:image][:attributes][:label][:example]	 				= "image_bgrnd.label = \"Background Image::\""

		lang_arr[:DOM][:image][:attributes][:extended_info] = Hash.new
		lang_arr[:DOM][:image][:attributes][:extended_info][:operators] 		= ["="]
		lang_arr[:DOM][:image][:attributes][:extended_info][:datatypes] 		= ["string"]
		lang_arr[:DOM][:image][:attributes][:extended_info][:allowed]			= ""
		lang_arr[:DOM][:image][:attributes][:extended_info][:default]			= ""
		lang_arr[:DOM][:image][:attributes][:extended_info][:infotext]			= "An additional text that can be shown to the user, for instance as help text"
		lang_arr[:DOM][:image][:attributes][:extended_info][:example]			= "image_largeimage.extended_info = \"The image should at least be 1000x1000 px CMYK\""

		lang_arr[:DOM][:image][:attributes][:value] = Hash.new
		lang_arr[:DOM][:image][:attributes][:value][:operators] 		 		= ["="]
		lang_arr[:DOM][:image][:attributes][:value][:datatypes] 				= ["string","t3path", "p3path"]
		lang_arr[:DOM][:image][:attributes][:value][:allowed]					= ""
		lang_arr[:DOM][:image][:attributes][:value][:default]					= ""
		lang_arr[:DOM][:image][:attributes][:value][:infotext]					= "Tells the system the right hand side of the assignment contains a value the contents of the image should be replaced with"
		lang_arr[:DOM][:image][:attributes][:value][:example]	 				= "image.bgrnd.value = \"page.56.field_p300Templavoila_bgrnd.value\""

		lang_arr[:DOM][:image][:attributes][:colorspace] = Hash.new
		lang_arr[:DOM][:image][:attributes][:colorspace][:operators] 			= ["="]
		lang_arr[:DOM][:image][:attributes][:colorspace][:datatypes] 			= ["string"]
		lang_arr[:DOM][:image][:attributes][:colorspace][:allowed]		 		= ["CMYK", "RGB", "BW"]
		lang_arr[:DOM][:image][:attributes][:colorspace][:default]		 		= ""
		lang_arr[:DOM][:image][:attributes][:colorspace][:infotext]		 		= "Restraints the image to a certain colorspace"
		lang_arr[:DOM][:image][:attributes][:colorspace][:example]	 			= "image_rgbimage.colorspace = \"RGB\""

		lang_arr[:DOM][:image][:attributes][:resolution] = Hash.new
		lang_arr[:DOM][:image][:attributes][:resolution][:operators] 			= ["="]
		lang_arr[:DOM][:image][:attributes][:resolution][:datatypes]	 		= ["number"]
		lang_arr[:DOM][:image][:attributes][:resolution][:allowed]		 		= ""
		lang_arr[:DOM][:image][:attributes][:resolution][:default]		 		= ""
		lang_arr[:DOM][:image][:attributes][:resolution][:infotext]		 		= "Defines what resolution an image should have at least"
		lang_arr[:DOM][:image][:attributes][:resolution][:example]	 			= "image_largeimage.resolution = 300"

		lang_arr[:DOM][:image][:attributes][:overflow] = Hash.new
		lang_arr[:DOM][:image][:attributes][:overflow][:operators]	 			= ["="]
		lang_arr[:DOM][:image][:attributes][:overflow][:datatypes] 				= ["string"]
		lang_arr[:DOM][:image][:attributes][:overflow][:allowed]		 		= ["scale", "crop"]
		lang_arr[:DOM][:image][:attributes][:overflow][:default]		 		= "scale"
		lang_arr[:DOM][:image][:attributes][:overflow][:infotext]		 		= "Defines what happpens when the image is larger than the image box."
		lang_arr[:DOM][:image][:attributes][:overflow][:example]	 			= "image_largeimage.overflow = \"crop\""

		lang_arr[:DOM][:image][:attributes][:align] = Hash.new
		lang_arr[:DOM][:image][:attributes][:align][:operators]	 				= ["="]
		lang_arr[:DOM][:image][:attributes][:align][:datatypes] 				= ["string"]
		lang_arr[:DOM][:image][:attributes][:align][:allowed]			 		= ["topleft", "topright", "bottomleft", "bottomright", "center"]
		lang_arr[:DOM][:image][:attributes][:align][:default]			 		= "center"
		lang_arr[:DOM][:image][:attributes][:align][:infotext]		 			= "Defines the alignment of an overflowing image with overflow set to 'crop'."
		lang_arr[:DOM][:image][:attributes][:align][:example]		 			= "image_largeimage.align = \"topleft\""

		lang_arr[:DOM][:image][:attributes][:use] = Hash.new
		lang_arr[:DOM][:image][:attributes][:use][:operators]	 				= ["="]
		lang_arr[:DOM][:image][:attributes][:use][:datatypes] 					= ["string"]
		lang_arr[:DOM][:image][:attributes][:use][:allowed]			 			= ["FE", "BE"]
		lang_arr[:DOM][:image][:attributes][:use][:default]			 			= ""
		lang_arr[:DOM][:image][:attributes][:use][:infotext]		 			= "Defines whether the image field should be parsed at the frontend (FE) or the backend (BE)"
		lang_arr[:DOM][:image][:attributes][:use][:example]		 				= "image_promotionimage.use = \"FE\""

		lang_arr[:DOM][:image][:attributes][:visible] = Hash.new
		lang_arr[:DOM][:image][:attributes][:visible][:operators]	 			= ["="]
		lang_arr[:DOM][:image][:attributes][:visible][:datatypes]	 			= ["boolean", "t3path"] 
		lang_arr[:DOM][:image][:attributes][:visible][:allowed]			 		= ""
		lang_arr[:DOM][:image][:attributes][:visible][:default]		 			= true
		lang_arr[:DOM][:image][:attributes][:visible][:infotext]		 		= "Makes it possible to make an object invisible"
		lang_arr[:DOM][:image][:attributes][:visible][:example]	 				= "image_myimage.visible = false"

		lang_arr[:DOM][:image][:attributes][:isbackground] = Hash.new
		lang_arr[:DOM][:image][:attributes][:isbackground][:operators]			= ["="]
		lang_arr[:DOM][:image][:attributes][:isbackground][:datatypes]			= ["boolean", "t3path"] 
		lang_arr[:DOM][:image][:attributes][:isbackground][:allowed]	 		= ""
		lang_arr[:DOM][:image][:attributes][:isbackground][:default]			= false
		lang_arr[:DOM][:image][:attributes][:isbackground][:infotext]		 	= "Sends image to back, usefull for spread wide background images to prevent overlap of right page."
		lang_arr[:DOM][:image][:attributes][:isbackground][:example]	 		= "image_myimage.isbackground = true"


		lang_arr[:DOM][:color] = Hash.new
		lang_arr[:DOM][:color][:attributes] = Hash.new

		lang_arr[:DOM][:color][:attributes][:label] = Hash.new
		lang_arr[:DOM][:color][:attributes][:label][:operators] 				= ["="]
		lang_arr[:DOM][:color][:attributes][:label][:datatypes] 				= ["string"]
		lang_arr[:DOM][:color][:attributes][:label][:allowed]		 			= ""
		lang_arr[:DOM][:color][:attributes][:label][:default]		 			= ""
		lang_arr[:DOM][:color][:attributes][:label][:infotext]		 			= "The label the colorinput will be provided with when presented to the user"
		lang_arr[:DOM][:color][:attributes][:label][:example]	 				= "color_bgrnd.label = \"Background Color:\""

		lang_arr[:DOM][:color][:attributes][:extended_info] = Hash.new
		lang_arr[:DOM][:color][:attributes][:extended_info][:operators] 		= ["="]
		lang_arr[:DOM][:color][:attributes][:extended_info][:datatypes] 		= ["string"]
		lang_arr[:DOM][:color][:attributes][:extended_info][:allowed]			= ""
		lang_arr[:DOM][:color][:attributes][:extended_info][:default]			= ""
		lang_arr[:DOM][:color][:attributes][:extended_info][:infotext]			= "An additional text that can be shown to the user, for instance as help text"
		lang_arr[:DOM][:color][:attributes][:extended_info][:example]			= "color_bgrnd.extended_info = \"Colors have to be entered as hexadecimal value\""

		lang_arr[:DOM][:color][:attributes][:value] = Hash.new
		lang_arr[:DOM][:color][:attributes][:value][:operators] 		 		= ["="]
		lang_arr[:DOM][:color][:attributes][:value][:datatypes] 				= ["string","t3path", "p3path"]
		lang_arr[:DOM][:color][:attributes][:value][:allowed]					= ""
		lang_arr[:DOM][:color][:attributes][:value][:default]					= ""
		lang_arr[:DOM][:color][:attributes][:value][:infotext]					= "Tells the system the right hand side of the assignment contains a value the contents of the colorfield should be replaced with"
		lang_arr[:DOM][:color][:attributes][:value][:example]	 				= "color.bgrnd.value = \"page.56.field_p300Templavoila_bgrnd.value\""

		lang_arr[:DOM][:color][:attributes][:colorspace] = Hash.new
		lang_arr[:DOM][:color][:attributes][:colorspace][:operators] 			= ["="]
		lang_arr[:DOM][:color][:attributes][:colorspace][:datatypes] 			= ["string"] 
		lang_arr[:DOM][:color][:attributes][:colorspace][:allowed]		 		= ["CMYK", "RGB", "BW"]
		lang_arr[:DOM][:color][:attributes][:colorspace][:default]		 		= ""
		lang_arr[:DOM][:color][:attributes][:colorspace][:infotext]		 		= "Restraints the colorinput to a certain colorspace"
		lang_arr[:DOM][:color][:attributes][:colorspace][:example]	 			= "color_bgrnd.colorspace = \"RGB\""

		lang_arr[:DOM][:color][:attributes][:visible] = Hash.new
		lang_arr[:DOM][:color][:attributes][:visible][:operators]	 			= ["="]
		lang_arr[:DOM][:color][:attributes][:visible][:datatypes]	 			= ["boolean", "t3path"] 
		lang_arr[:DOM][:color][:attributes][:visible][:allowed]			 		= ""
		lang_arr[:DOM][:color][:attributes][:visible][:default]		 			= true
		lang_arr[:DOM][:color][:attributes][:visible][:infotext]		 		= "Makes it possible to make an object invisible"
		lang_arr[:DOM][:color][:attributes][:visible][:example]	 				= "color_mycolor.visible = false"

		lang_arr[:DOM][:stack] = Hash.new
		lang_arr[:DOM][:stack][:attributes] = Hash.new

		lang_arr[:DOM][:stack][:attributes][:marginx] = Hash.new
		lang_arr[:DOM][:stack][:attributes][:marginx][:operators]	 			= ["="]
		lang_arr[:DOM][:stack][:attributes][:marginx][:datatypes]	 			= ["float"] 
		lang_arr[:DOM][:stack][:attributes][:marginx][:allowed]			 		= ""
		lang_arr[:DOM][:stack][:attributes][:marginx][:default]		 			= 0
		lang_arr[:DOM][:stack][:attributes][:marginx][:infotext]		 		= "Defines the margin on the x-axis between the registration points of repetative elements in a stack. \r"
		lang_arr[:DOM][:stack][:attributes][:marginx][:infotext]		 		+= "Negative values will result in a placement on the left side of the original object"
		lang_arr[:DOM][:stack][:attributes][:marginx][:example]	 				= "productname_stack.marginx = -50"

		lang_arr[:DOM][:stack][:attributes][:marginy] = Hash.new
		lang_arr[:DOM][:stack][:attributes][:marginy][:operators]	 			= ["="]
		lang_arr[:DOM][:stack][:attributes][:marginy][:datatypes]	 			= ["float"] 
		lang_arr[:DOM][:stack][:attributes][:marginy][:allowed]			 		= ""
		lang_arr[:DOM][:stack][:attributes][:marginy][:default]		 			= 0
		lang_arr[:DOM][:stack][:attributes][:marginy][:infotext]		 		= "Defines the margin on the y-axis between the registration points of repetative elements in a stack. \r"
		lang_arr[:DOM][:stack][:attributes][:marginy][:infotext]		 		+= "Negative values will result in a placement above of the original object"
		lang_arr[:DOM][:stack][:attributes][:marginy][:example]	 				= "productname_stack.marginy = 30"

		lang_arr[:DOM][:stack][:attributes][:maxuse] = Hash.new
		lang_arr[:DOM][:stack][:attributes][:maxuse][:operators]	 			= ["="]
		lang_arr[:DOM][:stack][:attributes][:maxuse][:datatypes]	 			= ["number"] 
		lang_arr[:DOM][:stack][:attributes][:maxuse][:allowed]			 		= ""
		lang_arr[:DOM][:stack][:attributes][:maxuse][:default]		 			= 0
		lang_arr[:DOM][:stack][:attributes][:maxuse][:infotext]			 		= "Indicates how many times this element can be repeated."
		lang_arr[:DOM][:stack][:attributes][:maxuse][:example]	 				= "mystack.maxuse = 5"

		lang_arr[:DOM][:object] = Hash.new
		lang_arr[:DOM][:object][:attributes] = Hash.new

		lang_arr[:DOM][:object][:attributes][:visible] = Hash.new
		lang_arr[:DOM][:object][:attributes][:visible][:operators]	 			= ["="]
		lang_arr[:DOM][:object][:attributes][:visible][:datatypes]	 			= ["boolean", "t3path"] 
		lang_arr[:DOM][:object][:attributes][:visible][:allowed]			 	= ""
		lang_arr[:DOM][:object][:attributes][:visible][:default]		 		= true
		lang_arr[:DOM][:object][:attributes][:visible][:infotext]		 		= "Makes it possible to make an object invisible"
		lang_arr[:DOM][:object][:attributes][:visible][:example]	 			= "object.visible = false"

		lang_arr[:commentblocks] = Hash.new

		lang_arr[:commentblocks][:single1] = Hash.new
		lang_arr[:commentblocks][:single1][:start] 	= "//"
		lang_arr[:commentblocks][:single1][:end] 	= "\r"

		lang_arr[:commentblocks][:single2] = Hash.new
		lang_arr[:commentblocks][:single2][:start] 	= "#"
		lang_arr[:commentblocks][:single2][:end] 	= "\r"

		lang_arr[:commentblocks][:multi1] = Hash.new
		lang_arr[:commentblocks][:multi1][:start] 	= "/*"
		lang_arr[:commentblocks][:multi1][:end] 	= "*/"

		lang_arr[:commentblocks][:multi2] = Hash.new
		lang_arr[:commentblocks][:multi2][:start] 	= "=begin"
		lang_arr[:commentblocks][:multi2][:end] 	= "=end"

		lang_arr[:T3S] = Hash.new

		lang_arr[:T3S][:classes] 	= ["page", "content", "file"]
		lang_arr[:T3S][:relative] 	= ["parent", "child", "this", "userselect"] 
		lang_arr[:T3S][:absolute] 	= ["number"] 
		lang_arr[:T3S][:attributes] = ["value"]

		lang_arr[:operators]	= Array.new
		lang_arr[:attributes]	= Array.new

		lang_arr[:DOM].each do |dom|
			dom[1][:attributes].each do |att|
					if(!lang_arr[:attributes].include?(att[0].to_s))
			    		lang_arr[:attributes] << att[0].to_s
					end
				att[1][:operators].each do |op|
					if(!lang_arr[:operators].include?(op))
						lang_arr[:operators] << op
					end
				end
			end
		end
		
		return lang_arr
	end
end
