
module TheFox
	module TermKit
		
		##
		# Basic Text View class. View sub-class.
		#
		# Provides functionalities to draw text.
		class TextView < View
			
			def initialize(text = nil, name = 'text_view')
				super(name)
				
				#puts 'TextView->initialize'
				
				if !text.nil?
					draw_text(text)
				end
			end
			
			def text=(text)
				if !text.is_a?(String)
					raise ArgumentError, "Argument is not a String -- #{text.class} given"
				end
				
				draw_text(text)
			end
			
			def draw_text(text)
				changes = 0
				
				y_pos = 0
				text.split("\n").each do |line|
					x_pos = 0
					
					# puts "line '#{line}'"
					
					line.split('').each do |char|
						# puts "c '#{char}'"
						
						content = draw_point(Point.new(x_pos, y_pos), char)
						if !content.nil?
							changes += 1
						end
						
						# puts "    c '#{char}' #{changes}"
						
						x_pos += 1
					end
					
					# puts "line '#{line}', changes #{changes}"
					
					y_pos += 1
				end
				
				changes
			end
			
		end
		
	end
end
