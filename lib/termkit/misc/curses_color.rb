
require 'curses'

module TheFox
	module TermKit
		
		class CursesColor
			
			COLORS = {
				:color_black => Curses::COLOR_BLACK,
				:color_blue => Curses::COLOR_BLUE,
				:color_cyan => Curses::COLOR_CYAN,
				:color_green => Curses::COLOR_GREEN,
				:color_magenta => Curses::COLOR_MAGENTA,
				:color_red => Curses::COLOR_RED,
				:color_white => Curses::COLOR_WHITE,
				:color_yellow => Curses::COLOR_YELLOW,
			}
			
		end
		
	end
end
