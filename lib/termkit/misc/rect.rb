
module TheFox
	module TermKit
		
		##
		# A composition of the Point class (`@origin` attribute) and the Size class (`@size` attribute).
		class Rect
			
			# Point instance.
			attr_reader :origin
			
			# Size instance.
			attr_reader :size
			
			attr_reader :x_range
			attr_reader :y_range
			
			def initialize(x = nil, y = nil, width = nil, height = nil)
				@origin = Point.new(x, y)
				@size = Size.new(width, height)
				set_x_range
				set_y_range
			end
			
			def origin=(origin)
				@origin = origin
				set_x_range
				set_y_range
			end
			
			def size=(size)
				@size = size
				set_x_range
				set_y_range
			end
			
			def x
				@origin.x
			end
			
			def x_max
				if !@origin.x.nil? && !@size.width.nil?
					@origin.x + @size.width - 1
				else
					-1
				end
			end
			
			def y
				@origin.y
			end
			
			def y_max
				if !@origin.y.nil? && !@size.height.nil?
					@origin.y + @size.height - 1
				else
					-1
				end
			end
			
			def width
				@size.width
			end
			
			def height
				@size.height
			end
			
			def has_default_values?
				@origin.x.nil? && @origin.y.nil? && @size.width.nil? && @size.height.nil?
			end
			
			def to_points
				points = []
				@x_range.each do |x_pos|
					@y_range.each do |y_pos|
						points << Point.new(x_pos, y_pos)
					end
				end
				points
			end
			
			def to_s
				x_s = x.nil? ? 'NIL' : x
				y_s = y.nil? ? 'NIL' : y
				
				w_s = width.nil? ? 'NIL' : width
				h_s = height.nil? ? 'NIL' : height
				
				"<Rect x=#{x_s} y=#{y_s} w=#{w_s} h=#{h_s}>"
			end
			
			def inspect
				to_s
			end
			
			private
			
			def set_x_range
				@x_range = Range.new(@origin.x.nil? ? 0: @origin.x, x_max)
			end
			
			def set_y_range
				@y_range = Range.new(@origin.y.nil? ? 0: @origin.y, y_max)
			end
			
		end
		
	end
end
