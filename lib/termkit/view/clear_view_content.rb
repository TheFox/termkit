
module TheFox
	module TermKit
		
		##
		# Use to clear a single point of a View.
		#
		# If a View disappears the screen needs to be cleaned or redrawn. An instance of this class should only be used temporary.
		class ClearViewContent < ViewContent
			
			def initialize(char = nil, view = nil, origin = nil)
				char ||= ' '
				
				super(char, view, origin)
			end
			
		end
		
	end
end
