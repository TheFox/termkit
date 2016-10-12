
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
			attr_reader :is_init_position
			
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
				@is_init_position = true
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
						
						new_area = Rect.new(nil, nil, x_max + 1, y_max + 1)
						new_area.origin = new_position
						new_area_points = new_area.to_points
						new_area_points_s = new_area_points.map{ |point| point.to_s }
						
						old_area = Rect.new(nil, nil, x_max + 1, y_max + 1)
						old_area.origin = old_position
						
						# puts "#{@name} -- plain area a=#{area.inspect}"
						
						# Redraw new position.
						puts "#{@name} -- new area #{new_area.inspect}"
						changes_new = @parent_view.redraw_area_zindex(new_area)
						# puts "#{@name} -- redraw_area_zindex OK #{new_area.inspect}"
						# STDIN.gets
						
						changes_new.each do |y_pos, row|
							#row.select{ |x_pos, content| !content.nil? }.each do |x_pos, content|
							row.each do |x_pos, content|
								new_point = Point.new(x_pos, y_pos)
								
								puts "#{@name} -- new content #{new_point} c=#{content.inspect}"
							end
						end
						
						puts
						puts "#{@name} -- @is_init_position = #{@is_init_position}"
						puts
						
						# Redraw old position.
						if !@is_init_position
							parent_view = @parent_view
							parent_level = 0
							point_offset = Point.new(0, 0)
							while parent_view
								puts "#{@name} -- l=#{parent_level} '#{parent_view}' -- old area #{old_area.inspect} #{point_offset}"
								old_points = old_area.to_points
								
								top_points = new_area_points.map{ |point| (point + point_offset) }
								#bottom_points = old_points.map{ |point| (point - point_offset).to_s }
								# rest_points = bottom_points - new_area_points
								rest_points_s = old_points.map{ |point| point.to_s } - top_points.map{ |point| point.to_s }
								rest_points = rest_points_s.map{ |point| Point.from_s(point) }
								#rest_points = old_points - top_points
								
								#puts "#{@name} -- original points #{old_area.to_points}"
								# puts "#{@name} -- top      points #{top_points}"
								# puts "#{@name} -- bottom   points #{bottom_points}"
								# puts "#{@name} -- new      points #{new_area_points}"
								# puts "#{@name} -- rest     points #{rest_points}"
								# puts "#{@name} -- rest s   points #{rest_points_s}"
								
								rest_points.each do |point|
									puts "#{@name} -- #{parent_view} -- old content #{point}"
									changed = parent_view.grid_cache_erase_point(point)
									puts "#{@name} -- #{parent_view} -- old content #{point} c=#{changed.inspect}"
								end
								
								# changes_old = {}
								#changes_old = parent_view.redraw_area_zindex(old_area)
								# STDIN.gets
								
								# puts "#{@name} -- #{parent_view} -- changed rows: #{changes_old.count}"
								# changes_old.each do |y_pos, row|
								# 	# puts "#{@name} -- #{parent_view} -- old row #{y_pos}, #{row.count} #{row.values.map{ |content| content.nil? ? nil : content.char }}"
								# 	row.each do |x_pos, content|
								# 		point = Point.new(x_pos, y_pos)
										
								# 		bottom_point = point - point_offset
								# 		bottom_point_x_pos, bottom_point_y_pos = bottom_point.to_a
										
								# 		new_content = changes_new[bottom_point_y_pos] && changes_new[bottom_point_y_pos][bottom_point_x_pos]
								# 		#puts "#{@name} -- #{parent_view} -- old content #{point} #{point_offset} #{bottom_point} n=#{new_content.inspect} c=#{content.inspect}"
										
								# 		unless new_content
								# 			changed = nil
								# 			# changed = parent_view.grid_cache_erase_point(point) # if point.to_s != '6:5' && point.to_s != '13:16'
											
								# 			# if content || changed
								# 			# 	puts "#{@name} -- #{parent_view} -- old content #{point} #{point_offset} #{bottom_point} co=#{content.inspect} ch=#{changed.inspect}"
								# 			# end
											
								# 		else
								# 			# puts "#{@name} -- #{parent_view} -- old content #{point} #{point_offset} #{bottom_point}, new"
								# 		end
								# 	end
								# end
								old_area.origin += parent_view.position
								point_offset += parent_view.position
								# puts "#{@name} -- #{parent_view} -- pos parent #{parent_view.position} -> #{old_area.inspect} #{point_offset.inspect}"
								# puts
								
								parent_view = parent_view.parent_view
								parent_level += 1
								
								puts
								
							end
							
						end
						
						puts
						
					end
				end
				
				@is_init_position = false
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
				
				# puts "#{@name} -- draw #{point} #{content.inspect}"
				
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
								# puts "#{@name} -- redraw parent, hide (#{@position.x}:#{@position.y}) #{x_pos}:#{y_pos}"
								
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
					
					# puts "#{@name} -- erase point #{point}, changed=#{changed ? 'Y' : 'N'}  #{changed.inspect}"
					
					# When nothing has changed.
					unless changed
						# puts "#{@name} -- erase point #{point}, nothing changed"
						
						content = ClearViewContent.new(nil, self, point)
						
						# puts "#{@name} -- erase point #{point}, set ClearViewContent"
						changed = set_grid_cache(point, content)
						# puts "#{@name} -- erase point #{point}, set ClearViewContent: #{changed.inspect}"
						
						#changed = content
					else
						# puts "#{@name} -- erase point #{point}, CHANGED #{changed.inspect}"
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
				
				# puts "#{@name} -- redraw point zindex #{point}"
				
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
					# When no subview was found, draw the current view
					# if a point on the current view's grid exist.
					
					# puts "#{@name} -- redraw point zindex #{point}, no view found"
					
					if @grid[y_pos] && @grid[y_pos][x_pos]
						# puts "#{@name} -- redraw point zindex #{point}, found something on the grid: '#{@grid[y_pos][x_pos]}'"
						content = @grid[y_pos][x_pos]
					else
						# puts "#{@name} -- redraw point zindex #{point}, nothing on grid @ #{x_pos}:#{y_pos}"
						
						if @grid_cache[y_pos] && @grid_cache[y_pos][x_pos]
							content = @grid_cache[y_pos][x_pos]
							
							unless content.is_a?(ClearViewContent)
								# puts "#{@name} -- redraw point zindex #{point}, found something on the grid_cache: '#{@grid_cache[y_pos][x_pos]}', DELETE"
								content = ClearViewContent.new(nil, self, point)
							end
						else
							# puts "#{@name} -- redraw point zindex #{point}, nothing on grid_cache @ #{x_pos}:#{y_pos}"
						end
					end
				else
					subview_x_pos = x_pos - view.position.x
					subview_y_pos = y_pos - view.position.y
					
					content = view.grid_cache[subview_y_pos][subview_x_pos]
					
					# puts "#{@name} -- redraw point zindex #{point}, last view: '#{view}' #{subview_x_pos}:#{subview_y_pos}  #{content.inspect}"
				end
				
				changed = nil
				unless content.nil?
					# puts "#{@name} -- redraw point zindex #{point}, set grid cache"
					changed = set_grid_cache(point, content)
				end
				
				if changed
					# puts "#{@name} -- redraw point zindex #{point}, changed #{content.inspect}"
					parent_draw_point(point, content)
				else
					# puts "#{@name} -- redraw point zindex #{point}, NOT changed"
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
			def set_grid_cache(point, new_content)
				x_pos, y_pos = point.to_a
				
				if !@grid_cache[y_pos]
					@grid_cache[y_pos] = {}
				end
				
				changed =
					if @grid_cache[y_pos][x_pos]
						old_content = @grid_cache[y_pos][x_pos]
						# puts "#{@name} -- set grid #{point}, x + y   ok"
						if old_content == new_content # && old_content.class == new_content.class
							# puts "#{@name} -- set grid #{point}, equals, #{old_content.inspect} == #{new_content.inspect}"
							false
						else
							# puts "#{@name} -- set grid #{point}, diff"
							if old_content.char == new_content.char && old_content.class == new_content.class
								new_content.needs_rendering = false
								@grid_cache[y_pos][x_pos] = new_content
								false
							else
								true
							end
						end
					else
						true
					end
				
				# puts "#{@name} -- set grid #{point} '#{new_content}' changed=#{changed ? 'Y' : 'N'}"
				
				if changed
					new_content.needs_rendering = true
					@grid_cache[y_pos][x_pos] = new_content
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
