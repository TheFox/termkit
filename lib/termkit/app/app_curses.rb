
require 'curses'
#require 'io/console'

module TheFox
	module TermKit
		
		# Default Curses read input timeout.
		CURSES_TIMEOUT = 200
		
		class CursesApp < UIApp
			
			def initialize
				@curses_timeout = CURSES_TIMEOUT
				
				@ui_inited = false
				@ui_closed = false
				
				super()
				
				#puts 'CursesApp->initialize'
			end
			
			def curses_timeout=(curses_timeout)
				@curses_timeout = curses_timeout
				Curses.timeout = @curses_timeout
			end
			
			##
			# See UIApp `run_cycle()` method.
			def run_cycle
				super()
				
				#puts 'CursesApp->run_cycle'
				
				handle_user_input
			end
			
			##
			# See UIApp `draw_point()` method.
			def draw_point(point, content)
				# @logger.debug("draw_point #{point} #{content.inspect}")
				
				content_s = content
				foreground_color = nil
				background_color = nil
				if content.is_a?(ViewContent)
					# @logger.debug("draw_point #{point} content is ViewContent")
					
					content_s = content.char
					
					# @logger.debug("draw_point #{point} #{content.foreground_color} #{content.background_color}")
					
					foreground_color = CursesColor::COLORS[content.foreground_color]
					background_color = CursesColor::COLORS[content.background_color]
				end
				
				c_attr = Curses::A_NORMAL
				
				if !foreground_color.nil? && !background_color.nil?
					Curses.init_pair(1, foreground_color, background_color)
					c_attr = Curses.color_pair(1)
				end
				
				# @logger.debug("draw_point #{point} '#{content_s}' #{foreground_color.inspect} #{background_color.inspect}")
				
				begin
					Curses.setpos(point.y, point.x)
					Curses.attron(c_attr) do
						Curses.addstr(content_s)
					end
				rescue Exception => e
					@logger.error("draw_point: #{e}")
				end
				
				# @logger.debug("draw_point #{point} #{content.inspect} DONE")
			end
			
			##
			# See UIApp `ui_refresh()` method.
			def ui_refresh
				Curses.refresh
			end
			
			##
			# See UIApp `ui_max_x()` method.
			def ui_max_x
				Curses.cols
			end
			
			##
			# See UIApp `ui_max_y()` method.
			def ui_max_y
				Curses.rows
			end
			
			protected
			
			##
			# See UIApp `ui_init()` method.
			def ui_init
				#puts "CursesApp->ui_init '#{@curses_timeout}'"
				
				raise 'ui already initialized' if @ui_inited
				@ui_inited = true
				
				super()
				
				# @logger.debug("init Curses")
				
				Curses.noecho
				Curses.timeout = @curses_timeout
				Curses.curs_set(0)
				Curses.init_screen
				Curses.start_color
				Curses.use_default_colors
				Curses.crmode
				Curses.stdscr.keypad(true)
				
				# @logger.debug("color_pairs: #{Curses.color_pairs}")
				
				# Curses.init_pair(1, Curses::COLOR_BLACK, Curses::COLOR_GREEN)
				
				# Curses.setpos(0, 0)
				# Curses.addstr('INIT OK')
				# Curses.refresh
			end
			
			##
			# See UIApp `ui_close()` method.
			def ui_close
				#puts "CursesApp->ui_close"
				
				raise 'ui already closed' if @ui_closed
				@ui_closed = true
				
				# Curses.setpos(10, 0)
				# Curses.addstr('CLOSE   ')
				# Curses.refresh
				# sleep(2)
				
				Curses.refresh
				Curses.stdscr.clear
				Curses.stdscr.refresh
				Curses.stdscr.close
				Curses.close_screen
			end
			
			private
			
			def handle_user_input
				key_down(Curses.getch)
				#key_down(IO.console.getch)
			end
			
		end
		
	end
end
