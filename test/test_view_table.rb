#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'
require 'pp'

class TestTableView < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_table_view
		view1 = TableView.new
		assert_instance_of(TableView, view1)
	end
	
	def test_size1
		view1 = TableView.new
		assert_equal(0, view1.page_height)
		
		view1.size = Size.new(nil, 5)
		assert_equal(5, view1.page_height)
		
		
		header1 = TextView.new("--HEADER A--\nHEADER B", 'header1')
		header1.is_visible = true
		view1.header = header1
		assert_equal(3, view1.page_height)
		
		header1.text = 'HEADER C'
		assert_equal(3, view1.page_height)
		
		header1 = TextView.new('--HEADER D--', 'header1')
		header1.is_visible = true
		view1.header = header1
		assert_equal(4, view1.page_height)
	end
	
	def test_size2
		header1 = TextView.new("--HEADER A--\nHEADER B", 'header1')
		header1.is_visible = true
		
		view1 = TableView.new
		view1.header = header1
		assert_equal(0, view1.page_height)
		
		view1.size = Size.new(nil, 6)
		assert_equal(4, view1.page_height)
	end
	
	def test_header
		view1 = TableView.new
		view1.header = View.new
		assert_instance_of(View, view1.header)
		
		view1.remove_header
		assert_nil(view1.header)
		assert_equal(0, view1.header_height)
	end
	
	def test_header_exception
		view1 = TableView.new
		assert_raises(ArgumentError){ view1.header = 'INVALID' }
	end
	
	def test_data1
		view1 = TableView.new('view1')
		
		view1.data = ['row A', 'row B', 'row C']
		cells = view1.cells
		assert_equal(3, cells.count)
		assert_instance_of(CellTableView, cells[0])
		assert_instance_of(CellTableView, cells[1])
		assert_instance_of(CellTableView, cells[2])
		assert_equal('cell_row_0', cells[0].name)
		assert_equal('cell_row_1', cells[1].name)
		assert_equal('cell_row_2', cells[2].name)
	end
	
	def test_data2
		view2 = TextView.new
		view2.is_visible = true
		view2.text = 'Foo Bar'
		
		cell1 = CellTableView.new(view2)
		cell1.name = 'cell_row_x'
		
		
		view1 = TableView.new('view1')
		
		view1.data = ['row A', 'row B', cell1]
		cells = view1.cells
		assert_equal(3, cells.count)
		assert_instance_of(CellTableView, cells[0])
		assert_instance_of(CellTableView, cells[1])
		assert_instance_of(CellTableView, cells[2])
		assert_equal('cell_row_0', cells[0].name)
		assert_equal('cell_row_1', cells[1].name)
		assert_equal('cell_row_x', cells[2].name)
	end
	
	def test_data_exception
		view1 = TableView.new
		assert_raises(ArgumentError){ view1.data = 'INVALID' }
		assert_raises(NotImplementedError){ view1.data = [1234] }
	end
	
	def test_cursor_position_scroll1
		view1 = TableView.new('view1')
		view1.size = Size.new(nil, 3)
		
		assert_equal(0, view1.cells_height_total)
		assert_equal(0, view1.cursor_position)
		assert_equal(0, view1.cursor_position_old)
		assert_equal(0, view1.cursor_direction)
		assert_equal(0, view1.page_begin)
		assert_equal(0, view1.page_direction)
		
		# Invalid cursor position because < 0.
		view1.cursor_position = -1
		assert_equal(0, view1.cells_height_total)
		assert_equal(0, view1.cursor_position)
		assert_equal(0, view1.cursor_position_old)
		assert_equal(0, view1.cursor_direction)
		assert_equal(0, view1.page_begin)
		assert_equal(0, view1.page_direction)
		
		# Invalid cursor position because list is empty.
		view1.cursor_position = 1
		assert_equal(0, view1.cells_height_total)
		assert_equal(0, view1.cursor_position)
		assert_equal(0, view1.cursor_position_old)
		assert_equal(0, view1.cursor_direction)
		assert_equal(0, view1.page_begin)
		assert_equal(0, view1.page_direction)
		
		# Invalid cursor position because list is empty.
		view1.cursor_position = 2
		assert_equal(0, view1.cells_height_total)
		assert_equal(0, view1.cursor_position)
		assert_equal(0, view1.cursor_position_old)
		assert_equal(0, view1.cursor_direction)
		assert_equal(0, view1.page_begin)
		assert_equal(0, view1.page_direction)
		
		
		view1.data = ['row A1', 'row B2', 'row C3', 'row D4', 'row E5']
		view1.cursor_position = 1
		assert_equal(5, view1.cells_height_total)
		assert_equal(1, view1.cursor_position)
		assert_equal(0, view1.cursor_position_old)
		assert_equal(1, view1.cursor_direction)
		assert_equal(0, view1.page_begin)
		assert_equal(0, view1.page_direction)
		
		view1.cursor_position = 1
		assert_equal(5, view1.cells_height_total)
		assert_equal(1, view1.cursor_position)
		assert_equal(1, view1.cursor_position_old)
		assert_equal(0, view1.cursor_direction)
		assert_equal(0, view1.page_begin)
		assert_equal(0, view1.page_direction)
		
		view1.cursor_position = 0
		assert_equal(5, view1.cells_height_total)
		assert_equal(0, view1.cursor_position)
		assert_equal(1, view1.cursor_position_old)
		assert_equal(-1, view1.cursor_direction)
		assert_equal(0, view1.page_begin)
		assert_equal(0, view1.page_direction)
		
		# Bottom position of current page.
		view1.cursor_position = 2
		assert_equal(5, view1.cells_height_total)
		assert_equal(2, view1.cursor_position)
		assert_equal(0, view1.cursor_position_old)
		assert_equal(1, view1.cursor_direction)
		assert_equal(0, view1.page_begin)
		assert_equal(0, view1.page_direction)
		
		# Move 1 page row down.
		view1.cursor_position = 3
		assert_equal(5, view1.cells_height_total)
		assert_equal(3, view1.cursor_position)
		assert_equal(2, view1.cursor_position_old)
		assert_equal(1, view1.cursor_direction)
		assert_equal(1, view1.page_begin)
		assert_equal(1, view1.page_direction)
		
		view1.cursor_position = 2
		assert_equal(5, view1.cells_height_total)
		assert_equal(2, view1.cursor_position)
		assert_equal(3, view1.cursor_position_old)
		assert_equal(-1, view1.cursor_direction)
		assert_equal(1, view1.page_begin)
		assert_equal(0, view1.page_direction)
		
		view1.cursor_position = 3
		assert_equal(5, view1.cells_height_total)
		assert_equal(3, view1.cursor_position)
		assert_equal(2, view1.cursor_position_old)
		assert_equal(1, view1.cursor_direction)
		assert_equal(1, view1.page_begin)
		assert_equal(0, view1.page_direction)
		
		# Bottom position of table.
		view1.cursor_position = 4
		assert_equal(5, view1.cells_height_total)
		assert_equal(4, view1.cursor_position)
		assert_equal(3, view1.cursor_position_old)
		assert_equal(1, view1.cursor_direction)
		assert_equal(2, view1.page_begin)
		assert_equal(1, view1.page_direction)
		
		# Want to go beyond bottom position of table.
		view1.cursor_position = 42
		assert_equal(5, view1.cells_height_total)
		assert_equal(4, view1.cursor_position)
		assert_equal(4, view1.cursor_position_old)
		assert_equal(0, view1.cursor_direction)
		assert_equal(2, view1.page_begin)
		assert_equal(0, view1.page_direction)
		
		# Move up.
		view1.cursor_position = 3
		assert_equal(5, view1.cells_height_total)
		assert_equal(3, view1.cursor_position)
		assert_equal(4, view1.cursor_position_old)
		assert_equal(-1, view1.cursor_direction)
		assert_equal(2, view1.page_begin)
		assert_equal(0, view1.page_direction)
		
		# Top position of current page.
		view1.cursor_position = 2
		assert_equal(5, view1.cells_height_total)
		assert_equal(2, view1.cursor_position)
		assert_equal(3, view1.cursor_position_old)
		assert_equal(-1, view1.cursor_direction)
		assert_equal(2, view1.page_begin)
		assert_equal(0, view1.page_direction)
		
		# Move 1 page row up.
		view1.cursor_position = 1
		assert_equal(5, view1.cells_height_total)
		assert_equal(1, view1.cursor_position)
		assert_equal(2, view1.cursor_position_old)
		assert_equal(-1, view1.cursor_direction)
		assert_equal(1, view1.page_begin)
		assert_equal(-1, view1.page_direction)
		
		# Top position of table.
		view1.cursor_position = 0
		assert_equal(5, view1.cells_height_total)
		assert_equal(0, view1.cursor_position)
		assert_equal(1, view1.cursor_position_old)
		assert_equal(-1, view1.cursor_direction)
		assert_equal(0, view1.page_begin)
		assert_equal(-1, view1.page_direction)
	end
	
	def test_cursor_position_scroll2
		view1 = TableView.new('view1')
		view1.size = Size.new(nil, 3)
		view1.data = ['row A', 'row B', 'row C', 'row D', 'row E', 'row F', 'row G']
		
		assert_equal(7, view1.cells_height_total)
		
		view1.cursor_position = 5
		assert_equal(5, view1.cursor_position)
		assert_equal(0, view1.cursor_position_old)
		assert_equal(1, view1.cursor_direction)
		assert_equal(3, view1.page_begin)
		assert_equal(1, view1.page_direction)
		
		view1.cursor_position = 3
		assert_equal(3, view1.cursor_position)
		assert_equal(5, view1.cursor_position_old)
		assert_equal(-1, view1.cursor_direction)
		assert_equal(3, view1.page_begin)
		assert_equal(0, view1.page_direction)
	end
	
	def test_cursor_position_change_data1
		view1 = TableView.new('view1')
		view1.size = Size.new(nil, 3)
		
		view1.data = ['row A', 'row B', 'row C', 'row D', 'row E']
		view1.cursor_position = 4
		assert_equal(5, view1.cells_height_total)
		assert_equal(2, view1.page_begin)
		
		view1.data = ['row F', 'row G', 'row H', 'row I']
		assert_equal(4, view1.cells_height_total)
		assert_equal(3, view1.cursor_position)
		assert_equal(1, view1.page_begin)
		
		view1.data = ['row J', 'row K', 'row L']
		assert_equal(3, view1.cells_height_total)
		assert_equal(2, view1.cursor_position)
		assert_equal(0, view1.page_begin)
		
		view1.data = ['row M', 'row N']
		assert_equal(2, view1.cells_height_total)
		assert_equal(1, view1.cursor_position)
		assert_equal(0, view1.page_begin)
		
		view1.data = ['row O']
		assert_equal(1, view1.cells_height_total)
		assert_equal(0, view1.cursor_position)
		assert_equal(0, view1.page_begin)
		
		view1.data = []
		assert_equal(0, view1.cells_height_total)
		assert_equal(0, view1.cursor_position)
		assert_equal(0, view1.page_begin)
	end
	
	def test_cursor_position_change_data2
		view1 = TableView.new('view1')
		view1.size = Size.new(nil, 3)
		
		view1.data = ['row A', 'row B', 'row C', 'row D', 'row E']
		view1.cursor_position = 3
		assert_equal(5, view1.cells_height_total)
		assert_equal(1, view1.page_begin)
		
		view1.data = ['row F', 'row G', 'row H', 'row I']
		assert_equal(4, view1.cells_height_total)
		assert_equal(3, view1.cursor_position)
		assert_equal(1, view1.page_begin)
		
		view1.data = ['row J', 'row K', 'row L']
		assert_equal(3, view1.cells_height_total)
		assert_equal(2, view1.cursor_position)
		assert_equal(0, view1.page_begin)
		
		view1.data = ['row M', 'row N']
		assert_equal(2, view1.cells_height_total)
		assert_equal(1, view1.cursor_position)
		assert_equal(0, view1.page_begin)
		
		view1.data = ['row O']
		assert_equal(1, view1.cells_height_total)
		assert_equal(0, view1.cursor_position)
		assert_equal(0, view1.page_begin)
		
		view1.data = []
		assert_equal(0, view1.cells_height_total)
		assert_equal(0, view1.cursor_position)
		assert_equal(0, view1.page_begin)
	end
	
	def test_cursor_position_change_size1
		view1 = TableView.new('view1')
		view1.data = ['row A', 'row B', 'row C', 'row D', 'row E']
		view1.cursor_position = 0
		
		view1.size = Size.new(nil, 3)
		assert_equal(0, view1.cursor_position)
		assert_equal(0, view1.page_begin)
		assert_equal(2, view1.page_end)
		
		view1.size = Size.new(nil, 2)
		assert_equal(0, view1.cursor_position)
		assert_equal(0, view1.page_begin)
		assert_equal(1, view1.page_end)
		
		view1.size = Size.new(nil, 1)
		assert_equal(0, view1.cursor_position)
		assert_equal(0, view1.page_begin)
		assert_equal(0, view1.page_end)
		
		view1.size = Size.new(nil, 4)
		assert_equal(0, view1.cursor_position)
		assert_equal(0, view1.page_begin)
		assert_equal(3, view1.page_end)
	end
	
	def test_cursor_position_change_size2
		view1 = TableView.new('view1')
		view1.data = ['row A', 'row B', 'row C', 'row D', 'row E', 'row F', 'row G']
		view1.cursor_position = 2
		
		view1.size = Size.new(nil, 3)
		assert_equal(2, view1.cursor_position)
		assert_equal(2, view1.page_begin)
		assert_equal(4, view1.page_end)
		
		view1.size = Size.new(nil, 2)
		assert_equal(2, view1.cursor_position)
		assert_equal(2, view1.page_begin)
		assert_equal(3, view1.page_end)
		
		view1.size = Size.new(nil, 1)
		assert_equal(2, view1.cursor_position)
		assert_equal(2, view1.page_begin)
		assert_equal(2, view1.page_end)
		
		view1.size = Size.new(nil, 4)
		assert_equal(2, view1.cursor_position)
		assert_equal(2, view1.page_begin)
		assert_equal(5, view1.page_end)
	end
	
	def test_is_cursor_at_bottom
		view1 = TableView.new('view1')
		view1.size = Size.new(nil, 3)
		view1.data = ['row A', 'row B', 'row C', 'row D', 'row E']
		assert_equal(false, view1.is_cursor_at_bottom?)
		
		view1.cursor_position = 1
		assert_equal(false, view1.is_cursor_at_bottom?)
		
		view1.cursor_position = 2
		assert_equal(false, view1.is_cursor_at_bottom?)
		
		view1.cursor_position = 3
		assert_equal(false, view1.is_cursor_at_bottom?)
		
		view1.cursor_position = 4
		assert_equal(true, view1.is_cursor_at_bottom?)
		
		view1.cursor_position = 3
		assert_equal(false, view1.is_cursor_at_bottom?)
	end
	
	def test_render_simple1
		view1 = TableView.new('view1')
		view1.data = ['row A1', 'row B2', 'row C3', 'row D4', 'row E5']
		
		rendered = view1.render
		
		assert_instance_of(Hash, rendered)
		assert_equal(5, rendered.count)
		assert_equal(6, rendered[0].count)
		assert_equal(6, rendered[1].count)
		assert_equal(6, rendered[2].count)
		assert_equal(6, rendered[3].count)
		assert_equal(6, rendered[4].count)
		
		assert_equal('r', rendered[0][0].char)
		assert_equal('o', rendered[0][1].char)
		assert_equal('w', rendered[0][2].char)
		assert_equal(' ', rendered[0][3].char)
		assert_equal('A', rendered[0][4].char)
		assert_equal('1', rendered[0][5].char)
		
		assert_equal('r', rendered[1][0].char)
		assert_equal('o', rendered[1][1].char)
		assert_equal('w', rendered[1][2].char)
		assert_equal(' ', rendered[1][3].char)
		assert_equal('B', rendered[1][4].char)
		assert_equal('2', rendered[1][5].char)
		
		assert_equal('r', rendered[2][0].char)
		assert_equal('o', rendered[2][1].char)
		assert_equal('w', rendered[2][2].char)
		assert_equal(' ', rendered[2][3].char)
		assert_equal('C', rendered[2][4].char)
		assert_equal('3', rendered[2][5].char)
		
		assert_equal('r', rendered[3][0].char)
		assert_equal('o', rendered[3][1].char)
		assert_equal('w', rendered[3][2].char)
		assert_equal(' ', rendered[3][3].char)
		assert_equal('D', rendered[3][4].char)
		assert_equal('4', rendered[3][5].char)
		
		assert_equal('r', rendered[4][0].char)
		assert_equal('o', rendered[4][1].char)
		assert_equal('w', rendered[4][2].char)
		assert_equal(' ', rendered[4][3].char)
		assert_equal('E', rendered[4][4].char)
		assert_equal('5', rendered[4][5].char)
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
	end
	
	def test_render_simple2
		view1 = TableView.new('view1')
		view1.size = Size.new(5, 3)
		view1.data = ['row A1', 'row B2', 'row C3', 'row D4', 'row E5']
		
		rendered = view1.render
		
		assert_instance_of(Hash, rendered)
		assert_equal(3, rendered.count)
		assert_equal(5, rendered[0].count)
		assert_equal(5, rendered[1].count)
		assert_equal(5, rendered[2].count)
		
		assert_equal('r', rendered[0][0].char)
		assert_equal('o', rendered[0][1].char)
		assert_equal('w', rendered[0][2].char)
		assert_equal(' ', rendered[0][3].char)
		assert_equal('A', rendered[0][4].char)
		
		assert_equal('r', rendered[1][0].char)
		assert_equal('o', rendered[1][1].char)
		assert_equal('w', rendered[1][2].char)
		assert_equal(' ', rendered[1][3].char)
		assert_equal('B', rendered[1][4].char)
		
		assert_equal('r', rendered[2][0].char)
		assert_equal('o', rendered[2][1].char)
		assert_equal('w', rendered[2][2].char)
		assert_equal(' ', rendered[2][3].char)
		assert_equal('C', rendered[2][4].char)
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
	end
	
	def test_render_scroll1
		view1 = TableView.new('view1')
		view1.size = Size.new(nil, 3)
		view1.data = ['row A1', 'row B2', 'row C3', 'row D4', 'row E']
		
		view1.render
		
		# puts '----- A -----'
		# puts; pp view1.grid_cache; puts
		view1.cursor_position = 4
		# puts; pp view1.grid_cache; puts
		
		rendered = view1.render
		puts; pp rendered; puts
		
		assert_instance_of(Hash, rendered)
		assert_equal(3, rendered.count)
		assert_equal(6, rendered[0].count)
		assert_equal(6, rendered[1].count)
		assert_equal(6, rendered[2].count)
		
		assert_equal('r', rendered[0][0].char)
		assert_equal('o', rendered[0][1].char)
		assert_equal('w', rendered[0][2].char)
		assert_equal(' ', rendered[0][3].char)
		assert_equal('C', rendered[0][4].char)
		assert_equal('3', rendered[0][5].char)
		
		assert_equal('r', rendered[1][0].char)
		assert_equal('o', rendered[1][1].char)
		assert_equal('w', rendered[1][2].char)
		assert_equal(' ', rendered[1][3].char)
		assert_equal('D', rendered[1][4].char)
		assert_equal('4', rendered[1][5].char)
		
		assert_equal('r', rendered[2][0].char)
		assert_equal('o', rendered[2][1].char)
		assert_equal('w', rendered[2][2].char)
		assert_equal(' ', rendered[2][3].char)
		assert_equal('E', rendered[2][4].char)
		assert_equal(' ', rendered[2][5].char)
		
		
		puts '----- SET 0 BEGIN -----'
		view1.cursor_position = 0
		puts '----- SET 0 END -------'
		
		rendered = view1.render
		puts; pp rendered; puts
		
		assert_equal(3, rendered.count)
		assert_equal(6, rendered[0].count)
		assert_equal(6, rendered[1].count)
		assert_equal(6, rendered[2].count)
		
		assert_equal('r', rendered[0][0].char)
		assert_equal('o', rendered[0][1].char)
		assert_equal('w', rendered[0][2].char)
		assert_equal(' ', rendered[0][3].char)
		assert_equal('A', rendered[0][4].char)
		assert_equal('1', rendered[0][5].char)
		
		assert_equal('r', rendered[1][0].char)
		assert_equal('o', rendered[1][1].char)
		assert_equal('w', rendered[1][2].char)
		assert_equal(' ', rendered[1][3].char)
		assert_equal('B', rendered[1][4].char)
		assert_equal('2', rendered[1][5].char)
		
		assert_equal('r', rendered[2][0].char)
		assert_equal('o', rendered[2][1].char)
		assert_equal('w', rendered[2][2].char)
		assert_equal(' ', rendered[2][3].char)
		assert_equal('C', rendered[2][4].char)
		assert_equal('3', rendered[2][5].char)
		
		
		puts '----- SET 4 BEGIN -----'
		view1.cursor_position = 4
		puts '----- SET 4 END -------'
		
		rendered = view1.render
		puts; pp rendered; puts
		
		assert_equal(3, rendered.count)
		assert_equal(6, rendered[0].count)
		assert_equal(6, rendered[1].count)
		assert_equal(6, rendered[2].count)
		
		assert_equal('r', rendered[0][0].char)
		assert_equal('o', rendered[0][1].char)
		assert_equal('w', rendered[0][2].char)
		assert_equal(' ', rendered[0][3].char)
		assert_equal('C', rendered[0][4].char)
		assert_equal('3', rendered[0][5].char)
		
		assert_equal('r', rendered[1][0].char)
		assert_equal('o', rendered[1][1].char)
		assert_equal('w', rendered[1][2].char)
		assert_equal(' ', rendered[1][3].char)
		assert_equal('D', rendered[1][4].char)
		assert_equal('4', rendered[1][5].char)
		
		assert_equal('r', rendered[2][0].char)
		assert_equal('o', rendered[2][1].char)
		assert_equal('w', rendered[2][2].char)
		assert_equal(' ', rendered[2][3].char)
		assert_equal('E', rendered[2][4].char)
		assert_equal(' ', rendered[2][5].char)
	end
	
	def test_render_scroll2
		view1 = TableView.new('view1')
		view1.size = Size.new(nil, 3)
		view1.data = ['A', 'AB', 'ABC', 'AB', 'A']
		
		# puts %(--- init done ---)
		# puts
		
		view1.cursor_position = 0
		rendered = view1.render
		assert_equal(3, rendered.count)
		
		
		view1.cursor_position = 1
		rendered = view1.render
		assert_equal(0, rendered.count)
		
		
		view1.cursor_position = 2
		rendered = view1.render
		assert_equal(0, rendered.count)
		
		
		puts %(--- SET 3 BEGIN ---)
		view1.cursor_position = 3
		puts %(--- SET 3 END -----)
		
		rendered = view1.render
		puts; pp rendered
		
		
		assert_equal(3, rendered.count)
		assert_equal(2, rendered[0].count)
		assert_equal(3, rendered[1].count)
		assert_equal(3, rendered[2].count)
		
		assert_equal('A', rendered[0][0].char)
		assert_equal('B', rendered[0][1].char)
		assert_equal('A', rendered[1][0].char)
		assert_equal('B', rendered[1][1].char)
		assert_equal('C', rendered[1][2].char)
		assert_equal('A', rendered[2][0].char)
		assert_equal('B', rendered[2][1].char)
		assert_equal(' ', rendered[2][2].char)
		
		
		puts %(--- set 4 ---)
		view1.cursor_position = 4
		rendered = view1.render
		pp rendered
		
		assert_equal(3, rendered.count)
		assert_equal(3, rendered[0].count)
		assert_equal(3, rendered[1].count)
		assert_equal(2, rendered[2].count)
		
		assert_equal('A', rendered[0][0].char)
		assert_equal('B', rendered[0][1].char)
		assert_equal('C', rendered[0][2].char)
		assert_equal('A', rendered[1][0].char)
		assert_equal('B', rendered[1][1].char)
		assert_equal(' ', rendered[1][2].char)
		assert_equal('A', rendered[2][0].char)
		assert_equal(' ', rendered[2][1].char)
		
		
		puts %(--- set 3 ---)
		view1.cursor_position = 3
		rendered = view1.render
		assert_equal(0, rendered.count)
		
		
		puts %(--- set 2 ---)
		view1.cursor_position = 2
		rendered = view1.render
		assert_equal(0, rendered.count)
		
		
		puts %(--- set 1 ---)
		view1.cursor_position = 1
		rendered = view1.render
		pp rendered
		
		assert_equal(3, rendered.count)
		assert_equal(3, rendered[0].count)
		assert_equal(3, rendered[1].count)
		assert_equal(2, rendered[2].count)
		
		assert_equal('A', rendered[0][0].char)
		assert_equal('B', rendered[0][1].char)
		assert_equal(' ', rendered[0][2].char)
		assert_equal('A', rendered[1][0].char)
		assert_equal('B', rendered[1][1].char)
		assert_equal('C', rendered[1][2].char)
		assert_equal('A', rendered[2][0].char)
		assert_equal('B', rendered[2][1].char)
		
		
		puts %(--- set 0 ---)
		view1.cursor_position = 0
		rendered = view1.render
		pp rendered
		
		assert_equal(3, rendered.count)
		assert_equal(2, rendered[0].count)
		assert_equal(3, rendered[1].count)
		assert_equal(3, rendered[2].count)
		
		assert_equal('A', rendered[0][0].char)
		assert_equal(' ', rendered[0][1].char)
		assert_equal('A', rendered[1][0].char)
		assert_equal('B', rendered[1][1].char)
		assert_equal(' ', rendered[1][2].char)
		assert_equal('A', rendered[2][0].char)
		assert_equal('B', rendered[2][1].char)
		assert_equal('C', rendered[2][2].char)
		
		# puts
	end
	
	def test_render_header1
		header1 = TextView.new('--H1--', 'header1')
		header1.is_visible = true
		
		view1 = TableView.new('view1')
		view1.size = Size.new(5, 3)
		view1.header = header1
		view1.data = ['row A1', 'row B2', 'row C3', 'row D4', 'row E5']
		
		rendered = view1.render
		
		assert_equal(3, rendered.count)
		assert_equal(5, rendered[0].count)
		assert_equal(5, rendered[1].count)
		assert_equal(5, rendered[2].count)
		
		assert_equal('-', rendered[0][0].char)
		assert_equal('-', rendered[0][1].char)
		assert_equal('H', rendered[0][2].char)
		assert_equal('1', rendered[0][3].char)
		assert_equal('-', rendered[0][4].char)
		
		assert_equal('r', rendered[1][0].char)
		assert_equal('o', rendered[1][1].char)
		assert_equal('w', rendered[1][2].char)
		assert_equal(' ', rendered[1][3].char)
		assert_equal('A', rendered[1][4].char)
		
		assert_equal('r', rendered[2][0].char)
		assert_equal('o', rendered[2][1].char)
		assert_equal('w', rendered[2][2].char)
		assert_equal(' ', rendered[2][3].char)
		assert_equal('B', rendered[2][4].char)
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
		pp rendered
		puts
	end
	
	def test_render_header2
		header1 = TextView.new(%{--H1--\n--H2--}, 'header1')
		header1.is_visible = true
		
		view1 = TableView.new('view1')
		view1.size = Size.new(5, 4)
		view1.header = header1
		view1.data = ['row A1', 'row B2', 'row C3', 'row D4', 'row E5']
		
		rendered = view1.render
		
		assert_equal(4, rendered.count)
		assert_equal(5, rendered[0].count)
		assert_equal(5, rendered[1].count)
		# assert_equal(5, rendered[2].count)
		
		assert_equal('H', rendered[0][2].char)
		assert_equal('1', rendered[0][3].char)
		
		assert_equal('H', rendered[1][2].char)
		assert_equal('2', rendered[1][3].char)
		
		assert_equal('A', rendered[2][4].char)
		assert_equal('B', rendered[3][4].char)
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
		pp rendered
		puts
	end
	
	def test_render_reset_header1
		header1 = TextView.new('--H1--', 'header1')
		header1.is_visible = true
		
		view1 = TableView.new('view1')
		view1.size = Size.new(5, 4)
		view1.header = header1
		view1.data = ['row A1', 'row B2', 'row C3', 'row D4', 'row E5']
		
		rendered = view1.render
		
		assert_equal(4, rendered.count)
		assert_equal(5, rendered[0].count)
		assert_equal(5, rendered[1].count)
		assert_equal(5, rendered[2].count)
		assert_equal(5, rendered[3].count)
		
		assert_equal('H', rendered[0][2].char)
		assert_equal('1', rendered[0][3].char)
		assert_equal('A', rendered[1][4].char)
		assert_equal('B', rendered[2][4].char)
		assert_equal('C', rendered[3][4].char)
		
		
		
		header2 = TextView.new(%{--H1--\n--H2--}, 'header2')
		header2.is_visible = true
		view1.header = header2
		
		rendered = view1.render
		# puts; pp rendered; puts
		
		assert_equal(4, rendered.count)
		assert_equal(5, rendered[0].count)
		assert_equal(5, rendered[1].count)
		assert_equal(5, rendered[2].count)
		assert_equal(5, rendered[3].count)
		
		assert_equal('H', rendered[0][2].char)
		assert_equal('1', rendered[0][3].char)
		assert_equal('H', rendered[1][2].char)
		assert_equal('2', rendered[1][3].char)
		assert_equal('A', rendered[2][4].char)
		assert_equal('B', rendered[3][4].char)
	end
	
	def test_render_reset_header2
		header1 = TextView.new('--H1--', 'header1')
		header1.is_visible = true
		
		view1 = TableView.new('view1')
		view1.size = Size.new(5, 4)
		view1.header = header1
		view1.data = ['row A1', 'row B2', 'row C3', 'row D4', 'row E5']
		view1.cursor_position = 3
		
		rendered = view1.render
		puts; pp rendered; puts
		
		assert_equal(4, rendered.count)
		assert_equal(5, rendered[0].count)
		assert_equal(5, rendered[1].count)
		assert_equal(5, rendered[2].count)
		assert_equal(5, rendered[3].count)
		
		assert_equal('H', rendered[0][2].char)
		assert_equal('1', rendered[0][3].char)
		assert_equal('B', rendered[1][4].char)
		assert_equal('C', rendered[2][4].char)
		assert_equal('D', rendered[3][4].char)
		
		
		header2 = TextView.new(%{--H1--\n--H2--}, 'header2')
		header2.is_visible = true
		view1.header = header2
		
		rendered = view1.render
		puts; pp rendered; puts
		
		assert_equal(4, rendered.count)
		assert_equal(5, rendered[0].count)
		assert_equal(5, rendered[1].count)
		assert_equal(5, rendered[2].count)
		assert_equal(5, rendered[3].count)
		
		assert_equal('H', rendered[0][2].char)
		assert_equal('1', rendered[0][3].char)
		assert_equal('H', rendered[1][2].char)
		assert_equal('2', rendered[1][3].char)
		assert_equal('B', rendered[2][4].char)
		assert_equal('C', rendered[3][4].char)
	end
	
	def test_render_scroll_header1
		header1 = TextView.new('--H1--', 'header1')
		header1.is_visible = true
		
		view1 = TableView.new('view1')
		view1.size = Size.new(5, 3)
		view1.header = header1
		view1.data = ['row A1', 'row B2', 'row C3', 'row D4', 'row E5']
		
		rendered = view1.render
		# pp rendered
		
		assert_equal(3, rendered.count)
		assert_equal(5, rendered[0].count)
		assert_equal(5, rendered[1].count)
		assert_equal(5, rendered[2].count)
		
		assert_equal('H', rendered[0][2].char)
		assert_equal('1', rendered[0][3].char)
		
		assert_equal('A', rendered[1][4].char)
		assert_equal('B', rendered[2][4].char)
		
		
		view1.cursor_position = 2
		
		rendered = view1.render
		puts; pp rendered; puts
		
		assert_equal(2, rendered.count)
		assert_equal(5, rendered[1].count)
		assert_equal(5, rendered[2].count)
		assert_equal('B', rendered[1][4].char)
		assert_equal('C', rendered[2][4].char)
		
		
		view1.cursor_position = 3
		
		rendered = view1.render
		puts; pp rendered; puts
		
		assert_equal(2, rendered.count)
		assert_equal(5, rendered[1].count)
		assert_equal(5, rendered[2].count)
		assert_equal('C', rendered[1][4].char)
		assert_equal('D', rendered[2][4].char)
	end
	
end
