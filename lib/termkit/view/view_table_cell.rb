
module TheFox
	module TermKit
		
		class CellTableView < View
			
			attr_reader :highlighted
			
			def initialize(subview, name = nil)
				name = "CellTableView_#{object_id}" if name.nil?
				super(name)
				
				@highlighted = false
				
				add_subview(subview)
			end
			
			def highlighted=(highlighted)
				if @highlighted != highlighted
					if highlighted
						foreground_color = :color_white
						background_color = :color_blue
					end
					@grid_cache.each do |y_pos, row|
						row.each do |x_pos, content|
							content.foreground_color = foreground_color
							content.background_color = background_color
						end
					end
				end
				
				@highlighted = highlighted
			end
			
		end
		
	end
end
