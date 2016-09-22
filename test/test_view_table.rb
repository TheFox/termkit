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
		
		view1.size = Size.new(3, 5)
		assert_equal(5, view1.page_height)
		
		
		header = TextView.new("--HEADER A--\nHEADER B")
		header.is_visible = true
		view1.header = header
		assert_equal(3, view1.page_height)
		
		header.text = 'HEADER C'
		assert_equal(3, view1.page_height)
		
		header = TextView.new('--HEADER D--')
		header.is_visible = true
		view1.header = header
		assert_equal(4, view1.page_height)
	end
	
	def test_size2
		header = TextView.new("--HEADER A--\nHEADER B")
		header.is_visible = true
		
		view1 = TableView.new
		view1.header = header
		assert_equal(0, view1.page_height)
		
		view1.size = Size.new(3, 6)
		assert_equal(4, view1.page_height)
	end
	
	def test_header_exception
		view1 = TableView.new
		assert_raises(ArgumentError){ view1.header = 'INVALID' }
	end
	
	def test_cursor_position_scroll
		view1 = TableView.new('view1')
		view1.size = Size.new(5, 3)
		
		assert_equal(0, view1.cursor_position)
		assert_equal(0, view1.cursor_position_old)
		assert_equal(0, view1.cursor_direction)
		assert_equal(0, view1.page_begin)
		assert_equal(0, view1.page_height_total)
		assert_equal(0, view1.page_direction)
		
		# Invalid cursor position because < 0.
		view1.cursor_position = -1
		assert_equal(0, view1.cursor_position)
		assert_equal(0, view1.cursor_position_old)
		assert_equal(0, view1.cursor_direction)
		assert_equal(0, view1.page_begin)
		assert_equal(0, view1.page_height_total)
		assert_equal(0, view1.page_direction)
		
		# Invalid cursor position because list is empty.
		view1.cursor_position = 1
		assert_equal(0, view1.cursor_position)
		assert_equal(0, view1.cursor_position_old)
		assert_equal(0, view1.cursor_direction)
		assert_equal(0, view1.page_begin)
		assert_equal(0, view1.page_height_total)
		assert_equal(0, view1.page_direction)
		
		# Invalid cursor position because list is empty.
		view1.cursor_position = 2
		assert_equal(0, view1.cursor_position)
		assert_equal(0, view1.cursor_position_old)
		assert_equal(0, view1.cursor_direction)
		assert_equal(0, view1.page_begin)
		assert_equal(0, view1.page_height_total)
		assert_equal(0, view1.page_direction)
		
		
		view1.data = ['row A1', 'row B2', 'row C3', 'row D4', 'row E5']
		view1.cursor_position = 1
		assert_equal(1, view1.cursor_position)
		assert_equal(0, view1.cursor_position_old)
		assert_equal(1, view1.cursor_direction)
		assert_equal(0, view1.page_begin)
		assert_equal(5, view1.page_height_total)
		assert_equal(0, view1.page_direction)
		
		view1.cursor_position = 1
		assert_equal(1, view1.cursor_position)
		assert_equal(1, view1.cursor_position_old)
		assert_equal(0, view1.cursor_direction)
		assert_equal(0, view1.page_begin)
		assert_equal(5, view1.page_height_total)
		assert_equal(0, view1.page_direction)
		
		view1.cursor_position = 0
		assert_equal(0, view1.cursor_position)
		assert_equal(1, view1.cursor_position_old)
		assert_equal(-1, view1.cursor_direction)
		assert_equal(0, view1.page_begin)
		assert_equal(5, view1.page_height_total)
		assert_equal(0, view1.page_direction)
		
		# Bottom position of current page.
		view1.cursor_position = 2
		assert_equal(2, view1.cursor_position)
		assert_equal(0, view1.cursor_position_old)
		assert_equal(1, view1.cursor_direction)
		assert_equal(0, view1.page_begin)
		assert_equal(5, view1.page_height_total)
		assert_equal(0, view1.page_direction)
		
		# Move 1 page row down.
		view1.cursor_position = 3
		assert_equal(3, view1.cursor_position)
		assert_equal(2, view1.cursor_position_old)
		assert_equal(1, view1.cursor_direction)
		assert_equal(1, view1.page_begin)
		assert_equal(5, view1.page_height_total)
		assert_equal(1, view1.page_direction)
		
		view1.cursor_position = 2
		assert_equal(2, view1.cursor_position)
		assert_equal(3, view1.cursor_position_old)
		assert_equal(-1, view1.cursor_direction)
		assert_equal(1, view1.page_begin)
		assert_equal(5, view1.page_height_total)
		assert_equal(0, view1.page_direction)
		
		view1.cursor_position = 3
		assert_equal(3, view1.cursor_position)
		assert_equal(2, view1.cursor_position_old)
		assert_equal(1, view1.cursor_direction)
		assert_equal(1, view1.page_begin)
		assert_equal(5, view1.page_height_total)
		assert_equal(0, view1.page_direction)
		
		# Bottom position of table.
		view1.cursor_position = 4
		assert_equal(4, view1.cursor_position)
		assert_equal(3, view1.cursor_position_old)
		assert_equal(1, view1.cursor_direction)
		assert_equal(2, view1.page_begin)
		assert_equal(5, view1.page_height_total)
		assert_equal(1, view1.page_direction)
		
		# Want to go beyond bottom position of table.
		view1.cursor_position = 42
		assert_equal(4, view1.cursor_position)
		assert_equal(4, view1.cursor_position_old)
		assert_equal(0, view1.cursor_direction)
		assert_equal(2, view1.page_begin)
		assert_equal(5, view1.page_height_total)
		assert_equal(0, view1.page_direction)
		
		# Move up.
		view1.cursor_position = 3
		assert_equal(3, view1.cursor_position)
		assert_equal(4, view1.cursor_position_old)
		assert_equal(-1, view1.cursor_direction)
		assert_equal(2, view1.page_begin)
		assert_equal(5, view1.page_height_total)
		assert_equal(0, view1.page_direction)
		
		# Top position of current page.
		view1.cursor_position = 2
		assert_equal(2, view1.cursor_position)
		assert_equal(3, view1.cursor_position_old)
		assert_equal(-1, view1.cursor_direction)
		assert_equal(2, view1.page_begin)
		assert_equal(5, view1.page_height_total)
		assert_equal(0, view1.page_direction)
		
		# Move 1 page row up.
		view1.cursor_position = 1
		assert_equal(1, view1.cursor_position)
		assert_equal(2, view1.cursor_position_old)
		assert_equal(-1, view1.cursor_direction)
		assert_equal(1, view1.page_begin)
		assert_equal(5, view1.page_height_total)
		assert_equal(-1, view1.page_direction)
		
		# Top position of table.
		view1.cursor_position = 0
		assert_equal(0, view1.cursor_position)
		assert_equal(1, view1.cursor_position_old)
		assert_equal(-1, view1.cursor_direction)
		assert_equal(0, view1.page_begin)
		assert_equal(5, view1.page_height_total)
		assert_equal(-1, view1.page_direction)
	end
	
	def test_cursor_position_change_data
		view1 = TableView.new('view1')
		view1.size = Size.new(5, 3)
		
		view1.data = ['row A', 'row B', 'row C', 'row D', 'row E']
		
		view1.cursor_position = 4
		assert_equal(2, view1.page_begin)
		assert_equal(5, view1.page_height_total)
		
		view1.data = ['row F', 'row G', 'row H', 'row I']
		
		assert_equal(3, view1.cursor_position)
		assert_equal(2, view1.page_begin)
		assert_equal(4, view1.page_height_total)
	end
	
	def test_render1
		# view1 = TableView.new('view1')
		# view1.size = Size.new(3, 5)
		# view1.data = ['row A1', 'row B2', 'row C3', 'row D4', 'row E5']
		
		# rendered = view1.render
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
		
		# assert_equal(3, rendered.count)
	end
	
	def test_render_exception
		view1 = TableView.new
		assert_raises(ArgumentError){ view1.data = 'INVALID' }
		assert_raises(NotImplementedError){ view1.data = [1234] }
	end
	
end
