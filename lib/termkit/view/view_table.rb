
# require 'pry'

module TheFox
	module TermKit
		
		##
		# View sub-class.
		#
		# Provides functionalities to show data in a scrollable table.
		class TableView < View
			
			attr_reader :header
			attr_reader :header_height
			# attr_reader :table
			attr_reader :data
			attr_reader :cells
			attr_reader :cells_height_total
			attr_accessor :highlighted_cell
			attr_reader :cursor_position
			attr_reader :cursor_position_old
			attr_reader :cursor_direction
			attr_reader :page_begin
			attr_reader :page_end
			attr_reader :page_height
			attr_reader :page_direction
			
			def initialize(name = nil)
				# puts "TableView initialize '#{name.inspect}'"
				super(name)
				
				@header = nil
				@header_height = 0
				@data = []
				@cells = []
				@cells_height_total = 0
				@highlighted_cell = nil
				
				@cursor_position = 0
				@cursor_position_old = 0
				@cursor_direction = 0
				
				@page_begin = 0
				@page_end = 0
				@page_height = 0
				@page_direction = 0
				@page_range = nil
				
				@table = View.new("#{@name}_table")
				@table.is_visible = true
				add_subview(@table)
			end
			
			def size=(size)
				super(size)
				
				calc_page_height
				calc_cursor
				calc_page
			end
			
			def header=(header)
				unless header.is_a?(View)
					raise ArgumentError, "Argument is not a View -- #{header.class} given"
				end
				
				unless @header.nil?
					remove_subview(@header)
				end
				
				@header = header
				unless header.nil?
					@header_height = @header.height
					
					add_subview(@header)
				end
				
				@table.position = Point.new(0, @header_height)
				
				calc_page_height
			end
			
			def remove_header
				@header = nil
				@header_height = 0
				
				@table.position = Point.new(0, @header_height)
				
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
					
					row_name = "row_#{cell_n}"
					
					case row
					when String
						text_view = TextView.new(row, "text_#{row_name}")
						text_view.is_visible = true
						# text_view.text = row
						
						cell = CellTableView.new(text_view, "cell_#{row_name}")
					when CellTableView
						cell = row
					else
						raise NotImplementedError, "Class '#{row.class}' not implemented yet"
					end
					
					@cells.push(cell)
					
					#cell.is_visible = false
					cell.is_visible = true
					#cell.position = Point.new(0, y_pos)
					#@table.add_subview(cell)
					
					y_pos += cell.height
					cell_n += 1
				end
				
				@cells_height_total = y_pos
				
				calc_page_height
				calc_cursor
				calc_page
			end
			
			def cursor_position=(cursor_position)
				@cursor_position_old = @cursor_position
				@cursor_position = cursor_position
				
				calc_cursor
				calc_page
			end
			
			def cursor_up
				self.cursor_position = @cursor_position - 1
			end
			
			def cursor_down
				self.cursor_position = @cursor_position + 1
			end
			
			def is_cursor_at_bottom?
				@cursor_position == @cells_height_total - 1
			end
			
			def render(area = nil)
				# refresh
				
				super(area)
			end
			
			def refresh
				new_page_range = Range.new(@page_begin, @page_end)
				
				#if new_page_range != @page_range
					# puts; puts; puts "#{@name} -- draw_cells r=#{new_page_range}"
					
					affected_cells = @cells[new_page_range]
					
					y_pos = 0
					cell_n = 0
					affected_cells.each do |cell|
						highlighted = @cursor_position == (cell_n + @page_begin)
						
						# puts "#{@name} -- [+] #{cell} n=#{cell_n} y=#{y_pos} h=#{highlighted ? 'Y' : 'N'}/#{cell.highlighted ? 'Y' : 'N'}"
						cell.highlighted = highlighted
						
						if highlighted
							@highlighted_cell = cell
						end
						
						# cell.size = Size.new(@size.width, nil)
						
						# puts "#{@name} -- [+] #{cell} y=#{y_pos} position"
						cell.position = Point.new(0, y_pos)
						
						unless @table.is_subview?(cell)
							# puts "#{@name} -- [+] #{cell} y=#{y_pos} add_subview"
							@table.add_subview(cell)
						end
						
						# puts "#{@name} -- [+] #{cell} y=#{y_pos} END"
						
						y_pos += cell.height
						cell_n += 1
					end
					
					# Hide out-of-scope cell(s) here. In the best case it's only ONE cell that will
					# be hidden. If you scroll down the top cell will be hidden, if you scroll up
					# only the bottom cell will be hidden.
					(@cells - affected_cells).select{ |cell| cell.is_visible? }.each do |cell|
						# puts "#{@name} -- [-] #{cell} y=#{cell.position.y} r?=#{cell.needs_rendering? ? 'Y' : 'N'}"
						@table.remove_subview(cell)
					end
				#end
				
				@page_range = new_page_range
			end
			
			private
			
			def calc_page_height
				# puts "calc_page_height"
				if @size.nil? || @size.height.nil?
					# puts "calc_page_height size is nil"
					@page_height = @cells_height_total
				else
					@page_height = @size.height - @header_height
				end
			end
			
			def calc_cursor
				# puts "calc_cursor @cursor_position '#{@cursor_position}' '#{@cells_height_total}'"
				
				if @cursor_position > @cells_height_total - 1
					@cursor_position = @cells_height_total - 1
				end
				if @cursor_position < 0
					@cursor_position = 0
				end
				
				# -1 up
				#  0 unchanged
				# +1 down
				# cds = '='
				if @cursor_position == @cursor_position_old
					@cursor_direction = 0
				elsif @cursor_position > @cursor_position_old
					@cursor_direction = 1
					# cds = 'v'
				else
					@cursor_direction = -1
					# cds = '^'
				end
				
				# puts "cursor n='#{@cursor_position}' o='#{@cursor_position_old}' d='#{cursor_direction}' t='#{cds}'"
			end
			
			def calc_page
				# -1 up
				#  0 unchanged
				# +1 down
				# pds = '='
				if @cursor_position > @page_end
					@page_direction = 1
					# pds = 'v'
				elsif @cursor_position < @page_begin
					@page_direction = -1
					# pds = '^'
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
				
				@page_end = @page_begin + @page_height - 1
				
				#puts "page   b=#{@page_begin} e=#{@page_end} m=#{page_begin_max} e=#{@page_end} h=#{@page_height} t=#{pds}"
			end
			
		end
		
	end
end
