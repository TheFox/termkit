
require 'thefox-ext'

module TheFox
	module TermKit
		
		##
		# Base View class
		#
		# A View is an abstraction of any view object.
		class View
			
			# The `name` variable is **for debugging only**.
			attr_accessor :name
			attr_accessor :parent_view
			attr_accessor :subviews
			attr_accessor :grid
			attr_accessor :grid_cache
			attr_reader :position
			attr_reader :zindex
			
			def initialize(name = nil)
				#puts 'View->initialize'
				
				@name = name # FOR DEBUG ONLY
				@parent_view = nil
				@subviews = []
				@grid = {}
				@grid_cache = {}
				
				@is_visible = false
				@position = Point.new(0, 0)
				@zindex = 1
			end
			
			##
			# FOR DEBUG ONLY
			def pp_grid
				@grid.map{ |y_pos, row|
					[y_pos, row.map{ |x_pos, content| [x_pos, content.char] }.to_h]
				}.to_h
			end
			
			##
			# FOR DEBUG ONLY
			def pp_grid_cache
				@grid_cache.map{ |y_pos, row|
					[y_pos,
						row.map{ |x_pos, content|
							# [x_pos, {'c' => content.char, 'v' => content.view.name}]
							[x_pos, content.char]
						}.to_h,
					]
				}.to_h
			end
			
			def is_visible=(is_visible)
				trend = 0
				
				if @is_visible && !is_visible
					trend = -1
				elsif !@is_visible && is_visible
					trend = 1
				end
				
				@is_visible = is_visible
				
				redraw_parent(trend)
			end
			
			def is_visible?
				@is_visible
			end
			
			def position=(position)
				if !position.is_a?(Point)
					raise ArgumentError, "Argument is not a Point -- #{position.class} given"
				end
				
				@position = position
			end
			
			def zindex=(zindex)
				@zindex = zindex
				
				puts "#{@name} -- set zindex #{zindex} p=#{@parent_view.nil? ? 'N' : 'Y'}"
				
				if !@parent_view.nil?
					@grid_cache.each do |y_pos, row|
						row.each do |x_pos, content|
							point = Point.new(x_pos + @position.x, y_pos + @position.y)
							
							puts "#{@name} -- set zindex #{zindex}, #{point.x}:#{point.y}"
							
							@parent_view.redraw_zindex(point)
						end
					end
				end
			end
			
			def add_subview(subview)
				if subview == self
					raise ArgumentError, 'self given'
				end
				if !subview.is_a?(View)
					raise ArgumentError, "Argument is not a View -- #{subview.class} given"
				end
				
				subview.parent_view = self
				r_subview = @subviews.push(subview)
				
				subview.grid_cache.each do |y_pos, row|
					row.each do |x_pos, content|
						point = Point.new(x_pos + subview.position.x, y_pos + subview.position.y)
						
						puts "#{@name} -- add_subview, redraw_zindex #{point.x}:#{point.y}"
						
						redraw_zindex(point)
					end
				end
				
				r_subview
			end
			
			def remove_subview(subview)
				if subview == self
					raise ArgumentError, 'self given'
				end
				if !subview.is_a?(View)
					raise ArgumentError, "Argument is not a View -- #{subview.class} given"
				end
				
				r_subview = @subviews.delete(subview)
				
				subview.grid_cache.each do |y_pos, row|
					row.each do |x_pos, content|
						point = Point.new(x_pos + subview.position.x, y_pos + subview.position.y)
						
						puts "#{@name} -- remove_subview, grid_cache_erase_point #{point.x}:#{point.y}"
						
						grid_cache_erase_point(point)
					end
				end
				
				r_subview
			end
			
			##
			# Draw a single Point to the current view.
			def draw_point(point, content)
				case point
				when Array, Hash
					point = Point.new(point)
				when Point
				else
					raise NotImplementedError, "#{content.class} class not implemented"
				end
				
				case content
				when String
					content = ViewContent.new(content, self)
				when ViewContent
				else
					raise NotImplementedError, "#{content.class} class not implemented"
				end
				
				is_foreign_point = content.view != self
				
				x_pos = point.x
				y_pos = point.y
				
				
				puts
				puts "#{@name} -- draw '#{content}'"
				
				
				if is_foreign_point
					x_pos += content.view.position.x
					y_pos += content.view.position.y
				else
					if !@grid[y_pos]
						@grid[y_pos] = {}
					end
					
					@grid[y_pos][x_pos] = content
				end
				
				new_point = Point.new(x_pos, y_pos)
				
				puts "#{@name} -- draw '#{content}' #{x_pos}:#{y_pos} foreign=#{is_foreign_point ? 'Y' : 'N'} from=#{content.view.name}"
				
				puts "#{@name} -- subviews: #{@subviews.count}"
				
				changed = false
				
				if @subviews.count == 0
					changed = set_grid_cache(new_point, content)
				else
					puts "#{@name} -- has subviews"
					
					if @grid_cache[y_pos] && @grid_cache[y_pos][x_pos]
						puts "#{@name} -- found something on cached grid"
						
						redraw_zindex(new_point)
					else
						puts "#{@name} -- draw free point"
						changed = set_grid_cache(new_point, content)
					end
				end
				
				if changed
					parent_draw_point(new_point, content)
				end
				
				return true
			end
			
			def parent_draw_point(point, content)
				if !@parent_view.nil? && is_visible?
					
					#point
					
					puts "#{@name} -- draw parent: #{@parent_view.name} #{point.x}:#{point.y}"
					@parent_view.draw_point(point, content)
				end
			end
			
			##
			# Redraw to Parent View based on the visibility trend.
			def redraw_parent(visibility_trend)
				puts "#{@name} -- redraw parent, #{visibility_trend}"
				
				if !@parent_view.nil?
					if visibility_trend == 1
						@grid_cache.each do |y_pos, row|
							row.each do |x_pos, content|
								puts "#{@name} -- redraw parent,  1, #{x_pos}:#{y_pos}"
								
								point = Point.new(x_pos, y_pos)
								@parent_view.draw_point(point, content)
							end
						end
					elsif visibility_trend == -1
						@grid_cache.each do |y_pos, row|
							row.each do |x_pos, content|
								parent_x_pos = x_pos + @position.x
								parent_y_pos = y_pos + @position.y
								
								puts "#{@name} -- redraw parent, -1, #{parent_x_pos}:#{parent_y_pos}"
								
								point = Point.new(parent_x_pos, parent_y_pos)
								
								if @parent_view.grid_cache[parent_y_pos] && 
									@parent_view.grid_cache[parent_y_pos][parent_x_pos] &&
									@parent_view.grid_cache[parent_y_pos][parent_x_pos] == content
									
									puts "#{@name} -- redraw parent, -1, #{parent_x_pos}:#{parent_y_pos}, erase"
									@parent_view.grid_cache_erase_point(point)
								else
									puts "#{@name} -- redraw parent, -1, #{parent_x_pos}:#{parent_y_pos}, not the same"
								end
							end
						end
					else
					end
				end
			end
			
			##
			# Erase a single Point of the Grid Cache.
			def grid_cache_erase_point(point)
				x_pos = point.x
				y_pos = point.y
				
				puts "#{@name} -- erase point, #{x_pos}:#{y_pos}"
				
				if @grid_cache[y_pos] && @grid_cache[y_pos][x_pos]
					#@grid_cache[y_pos][x_pos] = nil
					@grid_cache[y_pos].delete(x_pos)
					
					redraw_zindex(point)
				end
			end
			
			##
			# Redraw a single Point based on the zindexes of the subviews.
			# Happens when a subview added, removed, hides, or zindex changes.
			def redraw_zindex(point)
				x_pos = point.x
				y_pos = point.y
				
				puts "#{@name} -- redraw zindex #{x_pos}:#{y_pos}"
				
				views = @subviews
					.select{ |subview| subview.is_visible? }
					.select{ |subview| subview.zindex >= 1 }
					.select{ |subview|
						
						subview_x_pos = x_pos - subview.position.x
						subview_y_pos = y_pos - subview.position.y
						
						content = subview.grid_cache[subview_y_pos] && subview.grid_cache[subview_y_pos][subview_x_pos]
						
						# puts "#{@name} -- find #{subview_x_pos}:#{subview_y_pos} on cached grid in '#{subview}': '#{content}'"
						
						!content.nil?
					}
					.sort{ |subview1, subview2| subview1.zindex <=> subview2.zindex }
				
				pp views.map{ |subview| subview.name }
				
				view = views.last
				
				changed = false
				content = nil
				
				if view.nil?
					# When no subview was found draw the current view,
					# if a point on the current view's grid exist.
					
					puts "#{@name} -- redraw zindex, no view"
					
					if @grid[y_pos] && @grid[y_pos][x_pos]
						puts "#{@name} -- redraw zindex, found something on the grid: '#{@grid[y_pos][x_pos]}'"
						content = @grid[y_pos][x_pos]
						changed = set_grid_cache(point, content)
					else
						puts "#{@name} -- redraw zindex, nothing on the grid"
					end
				else
					puts "#{@name} -- redraw zindex, last view: '#{view}'"
					
					if @grid_cache[y_pos] && @grid_cache[y_pos][x_pos]
						subview_x_pos = x_pos - view.position.x
						subview_y_pos = y_pos - view.position.y
						
						content = view.grid_cache[subview_y_pos][subview_x_pos]
						
						puts "#{@name} -- redraw zindex, view '#{view}', point #{subview_x_pos}:#{subview_y_pos}: '#{content}'"
						
						changed = set_grid_cache(point, content)
					else
						puts "#{@name} -- redraw zindex, nothing on the cached grid"
					end
				end
				
				if changed
					puts "#{@name} -- redraw zindex, changed"
					parent_draw_point(point, content)
				end
				
				changed
			end
			
			def set_grid_cache(point, content)
				x_pos = point.x
				y_pos = point.y
				
				if !@grid_cache[y_pos]
					@grid_cache[y_pos] = {}
				end
				
				changed = if @grid_cache[y_pos][x_pos]
						if @grid_cache[y_pos][x_pos] == content
							false
						else
							true
						end
					else
						true
					end
				
				if changed
					@grid_cache[y_pos][x_pos] = content
				end
				
				puts "#{@name} -- set grid #{x_pos}:#{y_pos} '#{content}' changed=#{changed ? 'Y' : 'N'}"
				
				changed
			end
			
			def render
				
			end
			
			def to_s
				@name
			end
			
		end
		
	end
end
