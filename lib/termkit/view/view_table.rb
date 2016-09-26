
module TheFox
	module TermKit
		
		##
		# View sub-class.
		#
		# Provides functionalities to show data in a scrollable table.
		class TableView < View
			
			attr_reader :header
			attr_reader :data
			attr_reader :cells
			attr_reader :cursor_position
			attr_reader :cursor_position_old
			attr_reader :cursor_direction
			# attr_reader :page
			attr_reader :page_begin
			attr_reader :page_height
			attr_reader :cells_height_total
			attr_reader :page_direction
			# attr_reader :page_needs_refresh
			
			def initialize(name = nil)
				super(name)
				
				@header = nil
				@header_height = 0
				@data = []
				@cells = []
				
				@cursor_position = 0
				@cursor_position_old = 0
				@cursor_direction = 0
				
				# @page = []
				@page_begin = 0
				@page_height = 0
				@cells_height_total = 0
				@page_direction = 0
				# @page_needs_refresh = true
			end
			
			def size=(size)
				super(size)
				
				calc_page_height
			end
			
			def header=(header)
				if !header.is_a?(View)
					raise ArgumentError, "Argument is not a View -- #{header.class} given"
				end
				
				if !@header.nil?
					remove_subview(@header)
				end
				@header = header
				add_subview(@header)
				@header_height = @header.height
				
				calc_page_height
			end
			
			def data=(data)
				if !data.is_a?(Array)
					raise ArgumentError, "Argument is not a Array -- #{data.class} given"
				end
				
				@data = data
				@cells = []
				
				cell_n = 0
				y_pos = 0
				@data.each do |row|
					cell = nil
					cell_n += 1
					
					case row
					when String
						text_view = TextView.new()
						text_view.is_visible = true
						text_view.text = row
						
						cell = CellTableView.new(text_view)
						cell.name = "cell_#{cell_n}"
					when CellTableView
						cell = row
					else
						raise NotImplementedError, "Class '#{row.class}' not implemented yet"
					end
					
					@cells.push(cell)
					
					cell.is_visible = true
					cell.position = Point.new(0, y_pos)
					
					y_pos += cell.height
					
					# puts "#{cell_n} #{y_pos} #{cell}"
				end
				
				@cells_height_total = y_pos
				
				calc_cursor
				calc_page
				draw_data
			end
			
			def cursor_position=(cursor_position)
				@cursor_position_old = @cursor_position
				@cursor_position = cursor_position
				
				calc_cursor
				calc_page
			end
			
			def is_cursor_at_bottom?
				@cursor_position == @cells_height_total - 1
			end
			
			private
			
			def calc_page_height
				return if @size.nil? || @size.height.nil?
				
				# puts "calc_page_height '#{@size.height}' - '#{@header_height}'"
				@page_height = @size.height - @header_height
			end
			
			def calc_cursor
				puts "calc_cursor @cursor_position '#{@cursor_position}' '#{@cells_height_total}'"
				if @cursor_position > @cells_height_total - 1
					@cursor_position = @cells_height_total - 1
				end
				if @cursor_position < 0
					@cursor_position = 0
				end
				
				# -1 up
				#  0 unchanged
				# +1 down
				cds = '='
				if @cursor_position == @cursor_position_old
					@cursor_direction = 0
				elsif @cursor_position > @cursor_position_old
					@cursor_direction = 1
					cds = 'v'
				else
					@cursor_direction = -1
					cds = '^'
				end
				
				puts "cursor n='#{@cursor_position}' o='#{@cursor_position_old}' d='#{cursor_direction}' t='#{cds}'"
			end
			
			def calc_page
				page_end_old = @page_begin + @page_height - 1
				
				# -1 up
				#  0 unchanged
				# +1 down
				pds = '='
				if @cursor_position > page_end_old
					@page_direction = 1
					pds = 'v'
				elsif @cursor_position < @page_begin
					@page_direction = -1
					pds = '^'
				else
					@page_direction = 0
				end
				
				if @page_direction == 1
					@page_begin = @cursor_position - @page_height + 1
				elsif @page_direction == -1
					@page_begin = @cursor_position
				end
				
				page_begin_max = @cells_height_total - @page_height
				if page_begin_max < 0
					page_begin_max = 0
				end
				if @page_begin > page_begin_max
					@page_begin = page_begin_max
				end
				
				page_end = @page_begin + @page_height - 1
				
				puts "page   b='#{@page_begin}' (#{page_begin_max}) e='#{page_end}' t='#{pds}'"
			end
			
			def draw_data
				
			end
			
		end
		
	end
end
