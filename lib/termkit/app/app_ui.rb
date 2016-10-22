
module TheFox
	module TermKit
		
		class UIApp < App
			
			attr_accessor :app_controller
			attr_accessor :active_controller
			
			def initialize
				super()
				
				#puts 'UIApp initialize'
				
				@render_count = 0
				@app_controller = nil
				@active_controller = nil
				
				ui_init
			end
			
			##
			# See App `run_cycle()` method.
			def run_cycle
				super()
				
				#puts 'UIApp->run_cycle'
				
				render
			end
			
			def set_app_controller(app_controller)
				if !app_controller.is_a?(AppController)
					raise ArgumentError, "Argument is not a AppController -- #{app_controller.class} given"
				end
				
				@app_controller = app_controller
			end
			
			def set_active_controller(active_controller)
				if !active_controller.is_a?(ViewController)
					raise ArgumentError, "Argument is not a ViewController -- #{active_controller.class} given"
				end
				
				if !@active_controller.nil?
					@active_controller.inactive
				end
				
				@active_controller = active_controller
				@active_controller.active
			end
			
			##
			# Handles the actual rendering and drawing of the UI layer. Calls `draw_point()` for all points of `@active_controller`.
			def render
				#sleep 1 # @TODO: remove this line
				
				area = nil # @TODO: use current terminal size as area
				
				@render_count += 1
				# @logger.debug("--- RENDER: #{@render_count} ---")
				if !@active_controller.nil?
					# @logger.debug("RENDER active_controller OK: #{@active_controller.inspect}")
					# @logger.debug("RENDER active_controller view grid_cache: #{@active_controller.view.grid_cache.inspect}")
					
					@active_controller.render(area).each do |y_pos, row|
						row.each do |x_pos, content|
							#sleep 0.1 # @TODO: remove this line
							
							# @logger.debug("RENDER #{x_pos}:#{y_pos} '#{content}'")
							
							draw_point(Point.new(x_pos, y_pos), content)
							
							#ui_refresh # @TODO: remove this line
						end
					end
				end
				ui_refresh
			end
			
			def draw_line(point, row)
				x_pos = point.x
				y_pos = point.y
				
				row.length.times do |n|
					draw_point(Point.new(x_pos, y_pos), ViewContent.new(row[n]))
					x_pos += 1
				end
			end
			
			##
			# Needs to be implemented by the sub-class.
			#
			# For example, CursesApp is a sub-class of UIApp. CursesApp uses `Curses.setpos` and `Curses.addstr` in `draw_point()` to draw the points.
			def draw_point(point, content)
				raise NotImplementedError
			end
			
			def ui_refresh
				raise NotImplementedError
			end
			
			def ui_max_x
				-1
			end
			
			def ui_max_y
				-1
			end
			
			protected
			
			def app_will_terminate
				#puts 'UIApp app_will_terminate'
				
				ui_close
			end
			
			def ui_init
				# raise NotImplementedError
			end
			
			def ui_close
				# raise NotImplementedError
			end
			
			def key_down(key)
				if !key.nil? && !@active_controller.nil?
					event = KeyEvent.new
					event.key = key
					
					begin
						@active_controller.handle_event(event)
					rescue Exception::UnhandledKeyEventException => e
						@logger.warn("#{self.class} UnhandledKeyEventException: #{e}")
						
						if @app_controller.nil?
							@logger.warn("#{self.class} UnhandledKeyEventException: no app controller set, raise")
							
							raise e
						end
						
						@app_controller.handle_event(e.event)
					rescue Exception::UnhandledEventException => e
						@logger.warn("#{self.class} UnhandledEventException: #{e}")
					end
				end
			end
			
		end
		
	end
end
