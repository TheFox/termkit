
module TheFox
	module TermKit
		
		##
		# A single point on a x-y-grid.
		class Point
			
			attr_accessor :x
			attr_accessor :y
			
			def initialize(x = nil, y = nil)
				case x
				when Array
					y = x[1]
					x = x[0]
				when Hash
					y = if x['y']
							x['y']
						elsif x[:y]
							x[:y]
						end
					
					x = if x['x']
							x['x']
						elsif x[:x]
							x[:x]
						end
				end
				
				@x = x
				@y = y
			end
			
			def ==(point)
				@x == point.x && @y == point.y
			end
			
			def +(point)
				self.class.new(@x + point.x, @y + point.y)
			end
			
			def -(point)
				self.class.new(@x - point.x, @y - point.y)
			end
			
			def to_s
				"#{@x}:#{@y}"
			end
			
			def to_a
				[@x, @y]
			end
			
			def inspect
				x_s = x.nil? ? 'NIL' : x
				y_s = y.nil? ? 'NIL' : y
				
				"<Point x=#{x_s} y=#{y_s}>"
			end
			
			def self.from_s(s)
				x, y =
					s
					.split(/[:,]/, 2)
					.map{ |pos|
						pos.nil? || pos == '' ? nil : pos.to_i
					}
				
				new(x, y)
			end
			
		end
		
	end
end
