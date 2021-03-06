
module TheFox
	module TermKit
		
		class Size
			
			attr_accessor :width
			attr_accessor :height
			
			def initialize(width = nil, height = nil)
				@width = width
				@height = height
			end
			
			def to_s
				"#{@width}:#{@height}"
			end
			
			def inspect
				w_s = @width.nil? ? 'NIL' : @width.to_s
				h_s = @height.nil? ? 'NIL' : @height.to_s
				
				"#<Size w=#{w_s} h=#{h_s}>"
			end
			
		end
		
	end
end
