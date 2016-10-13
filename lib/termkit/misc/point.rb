
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
				# puts "Point == compare"
				@x == point.x && @y == point.y
			end
			
			# def ===(point)
			# 	puts "Point === compare"
			# 	#@x == point.x && @y == point.y
			# 	false
			# end
			
			# def eql?(point)
			# 	puts "Point eql? compare"
			# 	false
			# end
			
			def +(point)
				x = nil
				y = nil
				
				if !@x.nil? || !point.x.nil?
					x = @x.to_i + point.x.to_i
				end
				
				if !@y.nil? || !point.y.nil?
					y = @y.to_i + point.y.to_i
				end
				
				self.class.new(x, y)
			end
			
			def -(point)
				x = nil
				y = nil
				
				if !@x.nil? || !point.x.nil?
					x = @x.to_i - point.x.to_i
				end
				
				if !@y.nil? || !point.y.nil?
					y = @y.to_i - point.y.to_i
				end
				
				self.class.new(x, y)
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
				
				"#<Point x=#{x_s} y=#{y_s}>"
			end
			
			def missing_function
				
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
