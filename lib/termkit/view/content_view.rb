
module TheFox
	module TermKit
		
		##
		# Holds the character for a single Point of a View.
		class ViewContent
			
			attr_accessor :char
			attr_accessor :view
			
			# This variable is used to detect which of the points has already been rendered by the View.
			#
			# - If `true` View `render()` will return this instance.
			# - If `false` the content of the View didn't change since the last call of `render()` and the content has already been used in `render()`.
			attr_accessor :needs_rendering
			
			def initialize(char, view = nil)
				@char = char[0]
				@view = view
				@needs_rendering = true
			end
			
			def to_s
				@char
			end
			
			def inspect
				"<#{self.class.name.split('::').last} c='#{@char}' r?=#{@needs_rendering ? 'Y' : 'N'} v=#{@view}>"
			end
			
		end
		
	end
end
