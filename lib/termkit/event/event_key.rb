
module TheFox
	module TermKit
		
		##
		# Typically used to handle user keystrokes.
		class KeyEvent
			
			attr_accessor :key
			
			def initialize
				super()
				
				@key = nil
			end
			
			def to_s
				@key.to_s
			end
			
			def inspect
				s = "#<#{self.class}"
				unless @key.nil?
					s << "->#{@key.ord}[#{@key}]"
				end
				s << '>'
				s
			end
			
		end
		
	end
end
