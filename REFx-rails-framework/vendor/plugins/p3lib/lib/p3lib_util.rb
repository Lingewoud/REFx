# P3libUtil

## library for all helper classes

class P3libUtil
       
    def self.helper_newtempname(len)
		chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
		newpass = ""
		1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
		return newpass
	end
end

