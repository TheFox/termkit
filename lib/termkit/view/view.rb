
require 'thefox-ext'
require 'pp'

module TheFox
	module TermKit
		
		##
		# Base View class.
		#
		# A View is an abstraction of any view object.
		class View
			
			# The `name` variable is **FOR DEBUGGING ONLY**.
			attr_accessor :name
			attr_accessor :parent_view
			attr_accessor :subviews
			
			# Holds the content points for this View. A single point content is an instance of ViewContent class.
			attr_accessor :grid
			
			# Will be used for the actual rendering.  
			# The `@grid_cache` variable can hold *foreign* content points (see ViewContent) as well as own content points.
			# Foreign content points are owned by subviews that are shown on this View as well. If a View has subviews but no own content on the `@grid` the `@grid_cache` variable holds only content points from its subviews. The View not just holds the content points of the subviews but also the content points of the subviews of subviews and so on. Through the deepest level of subviews. If you draw a point on a View calling `draw_point()` the point will also be drawn on the parent view through the top view. `@grid` holds only ViewContents of its own View. Not so the `@grid_cache` variable that also holds foreign content points.
			attr_accessor :grid_cache
			
			attr_reader :position
			
			# Defines a maximum `width` and `height` (see Size) for a View to be rendered.
			attr_reader :size
			
			# Defines the stack order. This variable will only be used when the View has a parent view. The subview on the parent view with the highest zindex will be shown on the parent view. See `redraw_point_zindex()` method for details.
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
				@size = nil
				@zindex = 1
			end
			
			##
			# FOR DEBUG ONLY
			# :nocov:
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
			# :nocov:
			
			def is_visible=(is_visible)
				# puts "#{@name} -- is_visible= #{is_visible}"
				
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
			
			def position=(new_position)
				if !new_position.is_a?(Point)
					raise ArgumentError, "Argument is not a Point -- #{new_position.class} given"
				end
				
				puts "#{@name} -- position= old=#{@position} new=#{new_position}"
				
				if @position != new_position
					# puts "#{@name} -- position= diff"
					
					if @parent_view.nil?
						@position = new_position
					else
						# Keep old position.
						old_position = @position
						
						# Move it.
						@position = new_position
						
						area = Rect.new(nil, nil, x_max + 1, y_max + 1)
						
						puts "#{@name} -- plain area #{area.inspect}"
						
						# # Redraw new position.
						# area.origin = new_position
						# changes_new = @parent_view.redraw_area_zindex(area)
						# changes_new_a = changes_new.map{ |y_pos, row| row.keys.map{ |x_pos| Point.new(x_pos, y_pos).to_s } }.flatten
						# pp changes_new_a
						
						# # Redraw old position.
						# area.origin = old_position
						# changes_old = @parent_view.redraw_area_zindex(area)
						# changes_old_a = changes_old.map{ |y_pos, row| row.keys.map{ |x_pos| Point.new(x_pos, y_pos).to_s } }.flatten
						# pp changes_old_a
						
						
						# puts "#{@name} -- position= CHANGES START"
						
						# (changes_old_a - changes_new_a).each do |point_s|
						# 	point = Point.from_s(point_s)
						# 	x_pos, y_pos = point.to_a
							
						# 	has_grid = @parent_view.grid[y_pos] && @parent_view.grid[y_pos][x_pos]
						# 	has_grid_cache = @parent_view.grid_cache[y_pos] && @parent_view.grid_cache[y_pos][x_pos]
							
						# 	puts "#{@name} -- position= CHANGES, #{point} START"
							
						# 	changed = @parent_view.grid_cache_erase_point(point)
							
						# 	puts "#{@name} -- position= CHANGES, #{point} END"
						# end
						
						# Redraw new position.
						area.origin = new_position
						puts "#{@name} -- new area #{area.inspect}"
						changes_new = @parent_view.redraw_area_zindex(area)
						changes_new.each do |y_pos, row|
							row.select{ |x_pos, content| !content.nil? }.each do |x_pos, content|
							# row.each do |x_pos, content|
								puts "#{@name} -- new content #{x_pos}:#{y_pos} #{content.inspect}"
							end
						end
						
						puts
						puts
						puts
						
						# Redraw old position.
						area.origin = old_position
						parent_view = @parent_view
						while parent_view
							puts "#{@name} -- #{parent_view} -- old area #{area.inspect} #{area.x_range} #{area.y_range}"
							changes_old = parent_view.redraw_area_zindex(area)
							puts "#{@name} -- #{parent_view} -- changed rows: #{changes_old.count}"
							changes_old.each do |y_pos, row|
								# puts "#{@name} -- #{parent_view} -- old row #{y_pos}, #{row.count} #{row.values.map{ |content| content.nil? ? nil : content.char }}"
								row.each do |x_pos, content|
									point = Point.new(x_pos, y_pos)
									# changed = false
									changed = parent_view.grid_cache_erase_point(point)
									
									puts "#{@name} -- #{parent_view} -- old content #{point} #{content.inspect} #{changed.inspect}"
									# puts "#{@name} -- #{parent_view} -- old content #{point} #{content.inspect}"
								end
							end
							area.origin += parent_view.position
							puts "#{@name} -- #{parent_view} -- pos parent #{parent_view.position} -> #{area.inspect}"
							puts
							parent_view = parent_view.parent_view
							# break
						end
						
					end
				end
			end
			
			def top_position
				if @parent_view.nil?
					@position
				else
					@parent_view.top_position
				end
			end
			
			def position_path(point)
				
			end
			
			def size=(size)
				if !size.is_a?(Size)
					raise ArgumentError, "Argument is not a Size -- #{size.class} given"
				end
				
				@size = size
			end
			
			def zindex=(zindex)
				@zindex = zindex
				
				# puts "#{@name} -- set zindex #{zindex} p=#{@parent_view.nil? ? 'N' : 'Y'}"
				
				if !@parent_view.nil?
					@grid_cache.each do |y_pos, row|
						row.each do |x_pos, content|
							point = Point.new(x_pos + @position.x, y_pos + @position.y)
							
							# puts "#{@name} -- set zindex #{zindex}, #{point.x}:#{point.y}"
							
							@parent_view.redraw_point_zindex(point)
						end
					end
				end
			end
			
			def width
				keys = @grid_cache.map{ |y_pos, row| row.keys }.flatten
				min = keys.min.to_i
				max = keys.max.to_i
				
				puts "min '#{min}'"
				puts "max '#{max}'"
				puts
				
				if keys.count > 0
					max - min + 1
				else
					0
				end
			end
			
			def height
				keys = @grid_cache.keys
				# pp keys
				
				min = keys.min.to_i
				max = keys.max.to_i
				
				# puts "min '#{min}'"
				# puts "max '#{max}'"
				# puts
				
				if keys.count > 0
					max - min + 1
				else
					0
				end
			end
			
			def x_max
				@grid_cache.map{ |y_pos, row| row.keys.max }.flatten.max
			end
			
			def y_max
				@grid_cache.keys.max
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
						
						# puts "#{@name} -- add_subview, redraw_point_zindex #{point.x}:#{point.y}"
						
						redraw_point_zindex(point)
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
						
						# puts "#{@name} -- remove_subview, grid cache erase point #{point.x}:#{point.y}"
						
						grid_cache_erase_point(point)
					end
				end
				
				r_subview
			end
			
			def remove_subviews
				@subviews.each do |subview|
					remove_subview(subview)
				end
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
				
				
				if is_foreign_point
				else
					if !@grid[y_pos]
						@grid[y_pos] = {}
					end
					
					@grid[y_pos][x_pos] = content
					content.origin = point
				end
				
				puts "#{@name} -- draw #{point} #{content.inspect}"
				
				new_point = Point.new(x_pos, y_pos)
				
				# puts "#{@name} -- draw '#{content}' #{x_pos}:#{y_pos} foreign=#{is_foreign_point ? 'Y' : 'N'} from=#{content.view}"
				# puts "#{@name} -- subviews: #{@subviews.count}"
				
				changed = nil
				
				if @subviews.count == 0
					changed = set_grid_cache(new_point, content)
				else
					# puts "#{@name} -- has subviews"
					
					if @grid_cache[y_pos] && @grid_cache[y_pos][x_pos]
						# puts "#{@name} -- found something on cached grid"
						
						redraw_point_zindex(new_point)
					else
						# puts "#{@name} -- draw free point"
						changed = set_grid_cache(new_point, content)
					end
				end
				
				if changed
					parent_draw_point(new_point, content)
				end
				
				changed
			end
			
			# Draw a point on the parent View (`@parent_view`).
			def parent_draw_point(point, content)
				if !@parent_view.nil? && is_visible?
					
					new_point = Point.new(point.x + @position.x, point.y + @position.y)
					
					# puts "#{@name} -- draw parent: #{@parent_view} #{new_point.x}:#{new_point.y} (#{point.x}:#{point.y})"
					@parent_view.draw_point(new_point, content)
				end
			end
			
			##
			# Redraw to Parent View based on the visibility trend.  
			# The visibility trend is `0` for unchanged, `-1` will hide, `1` will appear.
			#
			# - `-1` means `is_visible` was set from `true` to `false`.
			# - `1` means `is_visible` was set from `false` to `true`.
			def redraw_parent(visibility_trend)
				# puts "#{@name} -- redraw parent, t=#{visibility_trend}"
				
				unless @parent_view.nil?
					if visibility_trend == 1
						
						@grid_cache.each do |y_pos, row|
							row.each do |x_pos, content|
								# puts "#{@name} -- redraw parent, draw, #{x_pos}:#{y_pos}"
								
								point = Point.new(x_pos, y_pos)
								parent_draw_point(point, content)
							end
						end
						
					elsif visibility_trend == -1
						
						@grid_cache.each do |y_pos, row|
							row.each do |x_pos, content|
								puts "#{@name} -- redraw parent, hide (#{@position.x}:#{@position.y}) #{x_pos}:#{y_pos}"
								
								view = @parent_view
								view_x_pos = x_pos + @position.x
								view_y_pos = y_pos + @position.y
								
								# Erase the content on all parent views.
								while !view.nil?
									# puts "#{@name} -- redraw parent, hide #{x_pos}:#{y_pos}, #{view}  #{view_x_pos}:#{view_y_pos}"
									
									view_content = view.grid_cache[view_y_pos] && view.grid_cache[view_y_pos][view_x_pos] ? view.grid_cache[view_y_pos][view_x_pos] : nil
									# view_content = view.grid[view_y_pos] && view.grid[view_y_pos][view_x_pos] ? view.grid[view_y_pos][view_x_pos] : nil
									
									if view_content
										
										# puts "#{@name} -- redraw parent, hide #{x_pos}:#{y_pos}, #{view}  #{view_x_pos}:#{view_y_pos}, content '#{view_content}'"
										
										# Erase the content on the parent view only when the content is viewable on the parent view.
										if view_content == content
											# puts "#{@name} -- redraw parent, hide #{x_pos}:#{y_pos}, #{view}  #{view_x_pos}:#{view_y_pos}, same"
											
											view.grid_cache_erase_point(Point.new(view_x_pos, view_y_pos))
										else
											# puts "#{@name} -- redraw parent, hide #{x_pos}:#{y_pos}, #{view}  #{view_x_pos}:#{view_y_pos}, not same"
											
											# Break when reaching a foreign layer (view). This can happen when this view
											# has a lower zindex and is concealed by another view.
											break
										end
										
									else
										# puts "#{@name} -- redraw parent, hide #{x_pos}:#{y_pos}, #{view}  #{view_x_pos}:#{view_y_pos}, empty"
									end
									
									
									view_x_pos += view.position.x
									view_y_pos += view.position.y
									view = view.parent_view
								end
								
							end
						end
						
					end
				end
			end
			
			def grid_erase
				@grid.each do |y_pos, row|
					row.each do |x_pos, content|
						#puts "clean #{x_pos}:#{y_pos} '#{content}'"
						point = Point.new(x_pos, y_pos)
						
						grid_erase_point(point)
					end
				end
			end
			
			def grid_erase_point(point)
				x_pos, y_pos = point.to_a
				
				@grid[y_pos][x_pos] = ClearViewContent.new(nil, self, point)
				grid_cache_erase_point(point)
			end
			
			##
			# Erase a single Point of the cached Grid (`@grid_cache`).
			#
			# First call `redraw_point_zindex(point)` to redraw the `point`. If the `point` didn't change use a new ClearViewContent instance and set it only on `@grid_cache`. Not on `@grid` because this clearing point instance will be removed by `render()`.
			def grid_cache_erase_point(point)
				x_pos, y_pos = point.to_a
				
				# puts "#{@name} -- erase point #{point}"
				
				changed = nil
				if @grid_cache[y_pos] && @grid_cache[y_pos][x_pos] && !@grid_cache[y_pos][x_pos].is_a?(ClearViewContent)
					# puts "#{@name} -- erase point #{point}, ok found & delete"
					@grid_cache[y_pos].delete(x_pos)
					if @grid_cache[y_pos].count == 0
						@grid_cache.delete(y_pos)
					end
					
					# puts "#{@name} -- erase point #{point}, redraw point zindex"
					changed = redraw_point_zindex(point)
					
					puts "#{@name} -- erase point #{point}, changed=#{changed ? 'Y' : 'N'}  #{changed.inspect}"
					
					# When nothing has changed.
					unless changed
						puts "#{@name} -- erase point #{point}, nothing changed"
						
						content = ClearViewContent.new(nil, self, point)
						
						# puts "#{@name} -- erase point #{point}, set ClearViewContent"
						set_grid_cache(point, content)
						
						changed = content
					else
						#puts "#{@name} -- erase point #{point}, CHANGED #{changed.inspect}"
						#set_grid_cache(point, changed)
					end
				else
					# puts "#{@name} -- erase point #{point}, not found"
				end
				changed
			end
			
			def grid_cache_remove_point(point, cls = nil)
				# puts "#{@name} -- remove point #{point}"
				
				x_pos, y_pos = point.to_a
				if @grid_cache[y_pos] && @grid_cache[y_pos][x_pos]
					# puts "#{@name} -- cls=#{cls.inspect} #{@grid_cache[y_pos][x_pos].class}"
					if cls.nil? || @grid_cache[y_pos][x_pos].is_a?(cls)
						# puts "#{@name} -- remove point #{point}, ok"
						@grid_cache[y_pos].delete(x_pos)
						
						if @grid_cache[y_pos].count == 0
							@grid_cache.delete(y_pos)
						end
					end
				else
					# puts "#{@name} -- remove point #{point}, not found"
				end
			end
			
			##
			# Redraw a single Point based on the `zindexes` of the subviews.  
			# Happens when a subview added, removed, hides, `zindex` changes, or draws.
			#
			# The subview with the highest `zindex` will be selected to set the content for this `point`. When no subview exists or all subviews are hidden look-up the Point on the `@grid` variable to set the Point on `@grid_cache`.
			def redraw_point_zindex(point)
				x_pos = point.x
				y_pos = point.y
				
				# puts "#{@name} -- redraw point zindex, #{point}"
				
				views = @subviews
					.select{ |subview| subview.is_visible? && subview.zindex >= 1 }
					.select{ |subview|
						
						subview_x_pos = x_pos - subview.position.x
						subview_y_pos = y_pos - subview.position.y
						
						content = subview.grid_cache[subview_y_pos] && subview.grid_cache[subview_y_pos][subview_x_pos]
						
						# puts "#{@name} -- find '#{subview}' #{subview_x_pos}:#{subview_y_pos}, #{content.inspect}"
						
						!content.nil?
					}
					.sort{ |subview1, subview2| subview1.zindex <=> subview2.zindex }
				
				# pp views.map{ |subview| subview.name }
				
				view = views.last
				
				content = nil
				
				if view.nil?
					# When no subview was found draw the current view,
					# if a point on the current view's grid exist.
					
					# puts "#{@name} -- redraw point zindex, no view found"
					
					if @grid[y_pos] && @grid[y_pos][x_pos]
						# puts "#{@name} -- redraw point zindex, found something on the grid: '#{@grid[y_pos][x_pos]}'"
						content = @grid[y_pos][x_pos]
					else
						# puts "#{@name} -- redraw point zindex, nothing on grid @ #{x_pos}:#{y_pos}"
					end
				else
					subview_x_pos = x_pos - view.position.x
					subview_y_pos = y_pos - view.position.y
					
					content = view.grid_cache[subview_y_pos][subview_x_pos]
					
					# puts "#{@name} -- redraw point zindex, last view: '#{view}' #{subview_x_pos}:#{subview_y_pos}  #{content.inspect}"
				end
				
				changed = nil
				unless content.nil?
					# puts "#{@name} -- redraw point zindex, set grid cache"
					changed = set_grid_cache(point, content)
				end
				
				if changed
					# puts "#{@name} -- redraw point zindex, changed"
					parent_draw_point(point, content)
				else
					# puts "#{@name} -- redraw point zindex, NOT changed"
				end
				
				changed
			end
			
			def redraw_area_zindex(area)
				if !area.is_a?(Rect)
					raise ArgumentError, "Argument is not a Rect -- #{area.class} given"
				end
				
				# puts "#{@name} -- redraw area  zindex, #{area} #{area.x_range} #{area.y_range}"
				
				changes = {}
				area.y_range.each do |y_pos|
					area.x_range.each do |x_pos|
						# puts "#{@name} -- redraw area  zindex, #{x_pos}:#{y_pos}"
						
						unless changes[y_pos]
							changes[y_pos] = {}
						end
						
						changes[y_pos][x_pos] = redraw_point_zindex(Point.new(x_pos, y_pos))
					end
				end
				changes
			end
			
			##
			# Set a single Point on the cached Grid (`@grid_cache`).  
			# This method returns `true` only if the content of the `point` has changed.
			def set_grid_cache(point, content)
				x_pos, y_pos = point.to_a
				
				if !@grid_cache[y_pos]
					@grid_cache[y_pos] = {}
				end
				
				changed =
					if @grid_cache[y_pos][x_pos]
						# puts "#{@name} -- set grid #{point}, x + y   ok"
						if @grid_cache[y_pos][x_pos] == content
							# puts "#{@name} -- set grid #{point}, equals, #{@grid_cache[y_pos][x_pos].inspect} == #{content.inspect}"
							false
						else
							# puts "#{@name} -- set grid #{point}, diff"
							if @grid_cache[y_pos][x_pos].char == content.char && @grid_cache[y_pos][x_pos].class == content.class
								content.needs_rendering = false
								@grid_cache[y_pos][x_pos] = content
								false
							else
								true
							end
						end
					else
						true
					end
				
				# puts "#{@name} -- set grid #{point} '#{content}' changed=#{changed ? 'Y' : 'N'}"
				
				if changed
					content.needs_rendering = true
					@grid_cache[y_pos][x_pos] = content
				end
			end
			
			##
			# Renders a View.
			#
			# Only ViewContents that needs a rendering (see ViewContent, `needs_rendering` attribute) will be returned. `needs_rendering` attribute is set to `false` by `render()`.
			def render(area = nil)
				# puts "#{@name} -- render area=#{area ? 'Y' : 'N'}"
				
				if !@size.nil?
					if area.nil?
						area = Rect.new(0, 0)
						area.size = @size
					end
				end
				
				grid_filtered = @grid_cache
				
				grid_filtered = grid_filtered
					.map{ |y_pos, row|
						[y_pos, row.select{ |x_pos, content| content.needs_rendering }]
					}
					.to_h
					
				
				if area.nil? || area.has_default_values?
					
				else
					
					grid_filtered = grid_filtered
						.select{ |y_pos, row|
							y_pos >= area.y
						}
						.map{ |y_pos, row|
							[y_pos, row.select{ |x_pos, content| x_pos >= area.x }]
						}
						.to_h
					
					if area.height
						grid_filtered = grid_filtered
							.select{ |y_pos, row|
								y_pos <= area.y_max
							}
					end
					
					if area.width
						grid_filtered = grid_filtered
							.map{ |y_pos, row|
								[y_pos, row.select{ |x_pos, content| x_pos <= area.x_max }]
							}
							.to_h
					end
					
				end
				
				grid_filtered = grid_filtered.select{ |y_pos, row| row.count > 0 }
				
				grid_filtered.each do |y_pos, row|
					row.each do |x_pos, content|
						point = Point.new(x_pos, y_pos)
						
						# puts "#{@name} -- render #{point}   #{content.inspect}"
						content.needs_rendering = false
						
						if content.is_a?(ClearViewContent)
							if @grid[y_pos] && @grid[y_pos][x_pos] && @grid[y_pos][x_pos].is_a?(ClearViewContent)
								# puts "#{@name} -- render remove grid ClearViewContent"
								@grid[y_pos].delete(x_pos)
							end
							
							parent_view = content.view
							parent_point = content.origin
							
							# puts "#{@name} -- render PARENT START '#{parent_point}'"
							while parent_view
								# puts "#{@name} -- render PARENT '#{parent_view}' '#{parent_point}' (#{parent_view.position})"
								
								# puts "#{@name} -- render remove grid_cache ClearViewContent"
								parent_view.grid_cache_remove_point(parent_point, ClearViewContent)
								
								parent_point += parent_view.position
								parent_view = parent_view.parent_view
								
								# sleep 0.1
							end
						end
					end
				end
				
				# @grid.values.map{ |row| row.values }.flatten.select{ |content| content.needs_rendering }.each do |content|
					# puts "render '#{content}'"
				# 	content.needs_rendering = false
				# end
				
				grid_filtered
			end
			
			def needs_rendering?
				@grid_cache
					.map{ |y_pos, row| row.values.map{ |content| content.needs_rendering ? 1 : 0 } }
					.flatten
					.inject(:+) > 0
			end
			
			def to_s
				@name
			end
			
			def inspect
				"<View name=#{@name} w=#{width}>"
			end
			
		end
		
	end
end
