
module TheFox
	module TermKit
		
		class ViewContent
			
			attr_accessor :char
			attr_accessor :view
			attr_accessor :needs_rendering
			
			def initialize(char, view = nil)
				@char = char[0]
				@view = view
				@needs_rendering = true
			end
			
			def to_s
				@char
			end
			
		end
		
	end
end
