#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'
# require 'pp'

class TestTextView < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_text_view
		view1 = TextView.new
		assert_instance_of(TextView, view1)
	end
	
	def test_render_single_line_base
		view1 = TextView.new('ABC', 'view1')
		
		rendered = view1.render
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
		
		assert_instance_of(Hash, rendered)
		assert_equal(1, rendered.count)
		
		assert_equal('A', rendered[0][0].char)
		assert_equal('B', rendered[0][1].char)
		assert_equal('C', rendered[0][2].char)
	end
	
	def test_render_single_line_redraw
		view1 = TextView.new('ABC', 'view1')
		
		rendered = view1.render
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
		
		assert_equal(1, rendered.count)
		assert_equal(3, rendered[0].count)
		
		assert_equal('A', rendered[0][0].char)
		assert_equal('B', rendered[0][1].char)
		assert_equal('C', rendered[0][2].char)
		
		
		assert_equal(3, view1.draw_text('AXC'))
		
		rendered = view1.render
		
		assert_equal(1, rendered.count)
		assert_equal(3, rendered[0].count)
		
		assert_equal('A', rendered[0][0].char)
		assert_equal('X', rendered[0][1].char)
		assert_equal('C', rendered[0][2].char)
	end
	
	def test_render_multi_line
		view1 = TextView.new("ABC\nDEF", 'view1')
		
		rendered = view1.render
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
		
		assert_equal(2, rendered.count)
		assert_equal(3, rendered[0].count)
		assert_equal(3, rendered[1].count)
		
		assert_equal('A', rendered[0][0].char)
		assert_equal('B', rendered[0][1].char)
		assert_equal('C', rendered[0][2].char)
		
		assert_equal('D', rendered[1][0].char)
		assert_equal('E', rendered[1][1].char)
		assert_equal('F', rendered[1][2].char)
	end
	
	def test_set_text_exception
		view1 = TextView.new
		assert_raises(ArgumentError){ view1.text = nil }
	end
	
end
