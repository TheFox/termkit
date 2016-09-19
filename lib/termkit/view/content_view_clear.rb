
module TheFox
	module TermKit
		
		class ClearViewContent < ViewContent
			
			def initialize(char = nil, view = nil)
				char ||= ' '
				
				super(char, view)
			end
			
		end
		
	end
end
