#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'
# require 'pp'

class TestView < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_view
		view1 = View.new
		assert_instance_of(View, view1)
	end
	
	def test_name
		view1 = View.new
		assert_nil(view1.name)
		
		view1 = View.new
		view1.name = 'view1'
		assert_equal('view1', view1.name)
		
		view1 = View.new('view1')
		assert_equal('view1', view1.name)
	end
	
	def test_is_visible1
		view1 = View.new
		assert_equal(false, view1.is_visible?)
		
		view1.is_visible = false
		assert_equal(false, view1.is_visible?)
		
		view1.is_visible = true
		assert_equal(true, view1.is_visible?)
		
		view1.is_visible = true
		assert_equal(true, view1.is_visible?)
		
		view1.is_visible = false
		assert_equal(false, view1.is_visible?)
	end
	
	def test_position_exception
		view1 = View.new
		
		assert_raises(ArgumentError){ view1.position = 'INVALID' }
	end
	
	def test_top_position
		view1 = View.new
		view1.position = Point.new(1, 4)
		
		view2 = View.new
		view2.position = Point.new(2, 5)
		view2.add_subview(view1)
		
		view3 = View.new
		view3.position = Point.new(3, 6)
		view3.add_subview(view2)
		
		assert_instance_of(Point, view1.top_position)
		assert_instance_of(Point, view2.top_position)
		assert_instance_of(Point, view3.top_position)
		assert_equal(3, view1.top_position.x)
		assert_equal(6, view1.top_position.y)
		assert_equal(3, view2.top_position.x)
		assert_equal(6, view2.top_position.y)
		assert_equal(3, view3.top_position.x)
		assert_equal(6, view3.top_position.y)
	end
	
	def test_size_exception
		view1 = View.new
		
		assert_raises(ArgumentError){ view1.size = 'INVALID' }
	end
	
	def test_width1
		view1 = View.new
		assert_equal(0, view1.width)
		
		view1.draw_point([0, 0], 'A')
		assert_equal(1, view1.width)
	end
	
	def test_width2
		view1 = View.new
		
		view1.draw_point([3, 0], 'A')
		# puts "'#{view1.width}'"
		assert_equal(1, view1.width)
		
		view1.draw_point([2, 1], 'A')
		view1.draw_point([3, 1], 'A')
		# puts "'#{view1.width}'"
		assert_equal(2, view1.width)
		
		view1.draw_point([1, 3], 'B')
		view1.draw_point([6, 3], 'B')
		# puts "'#{view1.width}'"
		assert_equal(6, view1.width)
	end
	
	def test_height
		view1 = View.new
		assert_equal(0, view1.height)
		
		view1.draw_point([0, 3], 'A')
		assert_equal(1, view1.height)
		
		view1.draw_point([1, 2], 'A')
		view1.draw_point([1, 4], 'A')
		assert_equal(3, view1.height)
	end
	
	def test_add_subview
		view1 = View.new
		view2 = View.new
		view3 = View.new
		view4 = View.new
		
		assert_equal(0, view1.subviews.count)
		
		view1.add_subview(view2)
		assert_equal(1, view1.subviews.count)
		assert_equal(view1, view2.parent_view)
		
		view1.add_subview(view3)
		assert_equal(2, view1.subviews.count)
		assert_equal(view1, view3.parent_view)
		
		view1.add_subview(view4)
		assert_equal(3, view1.subviews.count)
		assert_equal(view1, view4.parent_view)
	end
	
	def test_add_subview_exception
		view1 = View.new
		
		assert_raises(ArgumentError){ view1.add_subview(view1) }
		assert_raises(ArgumentError){ view1.add_subview('INVALID') }
	end
	
	def test_remove_subview
		view1 = View.new
		view2 = View.new
		view3 = View.new
		view4 = View.new
		
		view1.add_subview(view2)
		view1.add_subview(view3)
		view1.add_subview(view4)
		assert_equal(3, view1.subviews.count)
		
		assert_instance_of(View, view1.remove_subview(view3))
		assert_equal(2, view1.subviews.count)
		
		assert_nil(view1.remove_subview(view3))
		assert_equal(2, view1.subviews.count)
		
		assert_instance_of(View, view1.remove_subview(view2))
		assert_equal(1, view1.subviews.count)
		
		assert_instance_of(View, view1.remove_subview(view4))
		assert_equal(0, view1.subviews.count)
	end
	
	def test_remove_subview_exception
		view1 = View.new
		
		assert_raises(ArgumentError){ view1.remove_subview(view1) }
		assert_raises(ArgumentError){ view1.remove_subview('INVALID') }
	end
	
	def test_remove_subviews
		view1 = View.new
		view2 = View.new
		view3 = View.new
		view4 = View.new
		
		view1.add_subview(view2)
		view1.add_subview(view3)
		view1.add_subview(view4)
		assert_equal(3, view1.subviews.count)
		
		view1.remove_subviews
		assert_equal(0, view1.subviews.count)
	end
	
	def test_draw_point_simple
		view1 = View.new('view1')
		view1.is_visible = true
		
		assert_instance_of(ViewContent, view1.draw_point([0, 0], 'A'))
		assert_equal('A', view1.grid[0][0].char)
		assert_equal('A', view1.grid_cache[0][0].char)
	end
	
	def test_draw_point_subviews_base
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.position = Point.new(1, 0)
		view2.is_visible = true
		view1.add_subview(view2)
		
		assert_instance_of(ViewContent, view1.draw_point([0, 0], 'A'))
		assert_instance_of(ViewContent, view2.draw_point([0, 0], 'B'))
		
		assert_equal('A', view1.grid[0][0].char)
		assert_nil(view1.grid[0][1])
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
	end
	
	def test_draw_point_subviews_chain1
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.position = Point.new(2, 0)
		view2.is_visible = true
		view1.add_subview(view2)
		
		view3 = View.new('view3')
		view3.position = Point.new(3, 0)
		view3.is_visible = true
		view2.add_subview(view3)
		
		# assert_instance_of(ViewContent, view1.draw_point([0, 0], 'A'))
		# assert_instance_of(ViewContent, view1.draw_point([1, 0], 'A'))
		# assert_instance_of(ViewContent, view2.draw_point([0, 0], 'B'))
		# assert_instance_of(ViewContent, view2.draw_point([1, 0], 'B'))
		assert_instance_of(ViewContent, view3.draw_point([0, 0], 'C'))
		
		# pp view1.pp_grid_cache
		# pp view2.pp_grid_cache
		# pp view3.pp_grid_cache
		
		assert_equal('C', view3.grid_cache[0][0].char)
		assert_equal('C', view2.grid_cache[0][3].char)
		assert_equal('C', view1.grid_cache[0][5].char)
		
		# pp view3.grid_cache.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
		# pp view2.grid_cache.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
		# pp view1.grid_cache.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
	end
	
	def test_draw_point_subviews_chain2
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.position = Point.new(1, 0)
		view2.is_visible = true
		view1.add_subview(view2)
		
		view3 = View.new('view3')
		view3.position = Point.new(1, 0)
		view3.is_visible = true
		view2.add_subview(view3)
		
		assert_instance_of(ViewContent, view1.draw_point([0, 0], 'A'))
		assert_instance_of(ViewContent, view1.draw_point([1, 0], 'A'))
		assert_instance_of(ViewContent, view2.draw_point([0, 0], 'B'))
		assert_instance_of(ViewContent, view2.draw_point([1, 0], 'B'))
		assert_instance_of(ViewContent, view3.draw_point([0, 0], 'C'))
		
		# pp view1.pp_grid_cache
		# pp view2.pp_grid_cache
		# pp view3.pp_grid_cache
		
		assert_equal('C', view3.grid_cache[0][0].char)
		assert_equal('B', view2.grid_cache[0][0].char)
		assert_equal('C', view2.grid_cache[0][1].char)
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		assert_equal('C', view1.grid_cache[0][2].char)
	end
	
	def test_draw_point_subviews_chain3
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.position = Point.new(1, 0)
		view2.is_visible = true
		view1.add_subview(view2)
		
		view3 = View.new('view3')
		view3.position = Point.new(1, 0)
		view3.is_visible = true
		view2.add_subview(view3)
		
		assert_instance_of(ViewContent, view3.draw_point([0, 0], 'C'))
		
		# pp view1.pp_grid_cache
		# pp view2.pp_grid_cache
		# pp view3.pp_grid_cache
		
		assert_equal('C', view3.grid_cache[0][0].char)
		assert_equal('C', view2.grid_cache[0][1].char)
		assert_equal('C', view1.grid_cache[0][2].char)
		
		assert_nil(view2.draw_point([1, 0], 'B'))
		assert_instance_of(ViewContent, view2.draw_point([0, 0], 'B'))
		
		# pp view1.pp_grid_cache
		# pp view2.pp_grid_cache
		# pp view3.pp_grid_cache
		
		assert_equal('C', view3.grid_cache[0][0].char)
		assert_equal('C', view2.grid_cache[0][1].char)
		assert_equal('C', view1.grid_cache[0][2].char)
		
		assert_equal('B', view2.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		
		assert_nil(view1.draw_point([1, 0], 'A'))
		assert_instance_of(ViewContent, view1.draw_point([0, 0], 'A'))
		
		# pp view1.pp_grid_cache
		# pp view2.pp_grid_cache
		# pp view3.pp_grid_cache
	end
	
	def test_draw_point_visible_false
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.position = Point.new(1, 0)
		view2.is_visible = false
		view1.add_subview(view2)
		
		assert_instance_of(ViewContent, view1.draw_point([0, 0], 'A'))
		assert_instance_of(ViewContent, view2.draw_point([0, 0], 'B'))
		
		assert_equal('A', view1.grid[0][0].char)
		assert_nil(view1.grid[0][1])
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_nil(view1.grid_cache[0][1])
	end
	
	def test_draw_point_visible_true
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.position = Point.new(1, 0)
		view2.is_visible = false
		view1.add_subview(view2)
		
		assert_instance_of(ViewContent, view1.draw_point([0, 0], 'A'))
		assert_instance_of(ViewContent, view2.draw_point([0, 0], 'B'))
		
		assert_equal('A', view1.grid[0][0].char)
		assert_nil(view1.grid[0][1])
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_nil(view1.grid_cache[0][1])
		
		assert_equal('B', view2.grid[0][0].char)
		assert_equal('B', view2.grid_cache[0][0].char)
		
		view2.is_visible = true
		
		# pp view1.pp_grid_cache
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		
		view2.is_visible = false
		
		# pp view1.pp_grid_cache
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal(' ', view1.grid_cache[0][1].char)
	end
	
	def test_draw_point_zindex_base
		view1 = View.new('view1')
		view1.is_visible = true
		
		view3 = View.new('view3')
		view3.position = Point.new(2, 0)
		view3.is_visible = true
		view3.zindex = 2
		view1.add_subview(view3)
		
		view2 = View.new('view2')
		view2.position = Point.new(1, 0)
		view2.is_visible = true
		view2.zindex = 1
		view1.add_subview(view2)
		
		view4 = View.new('view4')
		view4.position = Point.new(2, 0)
		view4.is_visible = true
		view4.zindex = 3
		view1.add_subview(view4)
		
		assert_instance_of(ViewContent, view1.draw_point([0, 0], 'A'))
		assert_instance_of(ViewContent, view2.draw_point([0, 0], 'B'))
		assert_instance_of(ViewContent, view2.draw_point([1, 0], 'C'))
		assert_instance_of(ViewContent, view3.draw_point([0, 0], 'D'))
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		assert_equal('D', view1.grid_cache[0][2].char)
	end
	
	def test_draw_point_zindex_change1
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.position = Point.new(1, 0)
		view2.is_visible = true
		view2.zindex = 10
		view1.add_subview(view2)
		
		view3 = View.new('view3')
		view3.position = Point.new(2, 0)
		view3.is_visible = true
		view3.zindex = 20
		view1.add_subview(view3)
		
		assert_instance_of(ViewContent, view1.draw_point([0, 0], 'A'))
		assert_instance_of(ViewContent, view1.draw_point([1, 0], 'A'))
		assert_instance_of(ViewContent, view1.draw_point([2, 0], 'A'))
		assert_instance_of(ViewContent, view2.draw_point([0, 0], 'B'))
		assert_instance_of(ViewContent, view2.draw_point([1, 0], 'B'))
		assert_instance_of(ViewContent, view3.draw_point([0, 0], 'C'))
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		assert_equal('C', view1.grid_cache[0][2].char)
		
		# pp view1.pp_grid_cache
		
		view3.zindex = 10
		
		# pp view1.pp_grid_cache
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		assert_equal('C', view1.grid_cache[0][2].char)
		
		view3.zindex = 5
		
		# pp view1.pp_grid_cache
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		assert_equal('B', view1.grid_cache[0][2].char)
	end
	
	def test_draw_point_zindex_change2
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.position = Point.new(1, 0)
		view2.is_visible = true
		view1.add_subview(view2)
		
		view3 = View.new('view3')
		view3.position = Point.new(1, 0)
		view3.is_visible = true
		view3.zindex = 10
		view2.add_subview(view3)
		
		view4 = View.new('view4')
		view4.position = Point.new(1, 0)
		view4.is_visible = true
		view4.zindex = 20
		view2.add_subview(view4)
		
		assert_instance_of(ViewContent, view1.draw_point([0, 0], 'A'))
		assert_instance_of(ViewContent, view1.draw_point([1, 0], 'A'))
		assert_instance_of(ViewContent, view1.draw_point([2, 0], 'A'))
		# assert_instance_of(ViewContent, view1.draw_point([3, 0], 'A'))
		assert_instance_of(ViewContent, view2.draw_point([0, 0], 'B'))
		assert_instance_of(ViewContent, view2.draw_point([1, 0], 'B'))
		assert_instance_of(ViewContent, view2.draw_point([2, 0], 'B'))
		# assert_instance_of(ViewContent, view2.draw_point([3, 0], 'B'))
		assert_instance_of(ViewContent, view3.draw_point([0, 0], 'C'))
		assert_instance_of(ViewContent, view4.draw_point([0, 0], 'D'))
		assert_instance_of(ViewContent, view4.draw_point([1, 0], 'D'))
		
		# pp view1.pp_grid_cache
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		assert_equal('D', view1.grid_cache[0][2].char)
		assert_equal('D', view1.grid_cache[0][3].char)
		
		view4.zindex = 5
		
		# pp view1.pp_grid_cache
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		assert_equal('C', view1.grid_cache[0][2].char)
		assert_equal('D', view1.grid_cache[0][3].char)
		
		# puts '-' * 20
		# puts '-' * 20
		# puts '-' * 20
		
		view4.zindex = 0
		
		# puts '-' * 20
		# puts '-' * 20
		# puts '-' * 20
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		assert_equal('C', view1.grid_cache[0][2].char)
		assert_equal('B', view1.grid_cache[0][3].char)
		
		# pp view1.pp_grid_cache
		# pp view2.pp_grid_cache
		# pp view3.pp_grid_cache
		# pp view4.pp_grid_cache
	end
	
	def test_draw_point_add_subview
		view1 = View.new('view1')
		view1.is_visible = true
		
		assert_instance_of(ViewContent, view1.draw_point([0, 0], 'A'))
		assert_instance_of(ViewContent, view1.draw_point([1, 0], 'B'))
		assert_instance_of(ViewContent, view1.draw_point([2, 0], 'C'))
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		assert_equal('C', view1.grid_cache[0][2].char)
		
		view2 = View.new('view2')
		view2.position = Point.new(2, 0)
		view2.is_visible = true
		
		assert_instance_of(ViewContent, view2.draw_point([0, 0], 'D'))
		
		view1.add_subview(view2)
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		assert_equal('D', view1.grid_cache[0][2].char)
	end
	
	def test_draw_point_remove_subview
		view1 = View.new('view1')
		view1.is_visible = true
		
		assert_instance_of(ViewContent, view1.draw_point([0, 0], 'A'))
		assert_instance_of(ViewContent, view1.draw_point([1, 0], 'B'))
		assert_instance_of(ViewContent, view1.draw_point([2, 0], 'C'))
		
		view2 = View.new('view2')
		view2.position = Point.new(2, 0)
		view2.is_visible = true
		
		assert_instance_of(ViewContent, view2.draw_point([0, 0], 'D'))
		
		view1.add_subview(view2)
		
		# pp view1.pp_grid_cache
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		assert_equal('D', view1.grid_cache[0][2].char)
		
		view1.remove_subview(view2)
		
		# pp view1.pp_grid_cache
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		assert_equal('C', view1.grid_cache[0][2].char)
	end
	
	def test_draw_point_exception
		view1 = View.new
		
		assert_raises(NotImplementedError){ view1.draw_point(nil, nil) }
		assert_raises(NotImplementedError){ view1.draw_point(Point.new(0, 0), nil) }
	end
	
	def test_grid_erase1
		view1 = View.new('view1')
		view1.is_visible = true
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		view1.draw_point([2, 0], 'C')
		
		rendered = view1.render
		
		assert_equal(1, rendered.count)
		assert_equal(3, rendered[0].count)
		
		view1.grid_erase
		rendered = view1.render
		
		assert_equal(1, rendered.count)
		assert_equal(3, rendered[0].count)
		assert_equal(' ', rendered[0][0].char)
		assert_equal(' ', rendered[0][1].char)
		assert_equal(' ', rendered[0][2].char)
		
		rendered = view1.render
		
		assert_equal(0, rendered.count)
	end
	
	def test_redraw_point_zindex_base
		view1 = View.new('view1')
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		
		# Should return nil because nothing changed.
		assert_nil(view1.redraw_point_zindex(Point.new(0, 0)))
		
		# Should return nil because nothing changed.
		assert_nil(view1.redraw_point_zindex(Point.new(1, 0)))
		
		# Should return nil because this point is empty on @grid.
		assert_nil(view1.redraw_point_zindex(Point.new(2, 0)))
	end
	
	def test_redraw_point_zindex_subview
		view1 = View.new('view1')
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		
		view2 = View.new('view2')
		view2.position = Point.new(2, 3)
		view2.is_visible = true
		
		view1.add_subview(view2)
		
		# Should return nil because nothing changed.
		assert_nil(view1.redraw_point_zindex(Point.new(0, 0)))
		
		# Should return nil because nothing changed.
		assert_nil(view1.redraw_point_zindex(Point.new(1, 0)))
		
		# Should return nil because this point is empty on all layers.
		assert_nil(view1.redraw_point_zindex(Point.new(2, 0)))
		
		view1.draw_point([2, 3], 'C')
		assert_nil(view1.redraw_point_zindex(Point.new(2, 3)))
		
		
		view2.grid_cache[0] = view2.grid[0] = { }
		
		view2.grid_cache[0][0] = view2.grid[0][0] = ViewContent.new('D', view2)
		assert_equal(view2.grid[0][0], view1.redraw_point_zindex(Point.new(2, 3)))
		assert_nil(view1.redraw_point_zindex(Point.new(2, 3)))
		
		view2.grid_cache[0][1] = view2.grid[0][1] = ViewContent.new('E', view2)
		assert_equal(view2.grid[0][1], view1.redraw_point_zindex(Point.new(3, 3)))
		assert_nil(view1.redraw_point_zindex(Point.new(3, 3)))
	end
	
	def test_redraw_point_zindex_exception
		view1 = View.new('view1')
		assert_raises(ArgumentError){ view1.redraw_area_zindex('INVALID') }
	end
	
	def test_set_grid_cache
		content1 = ViewContent.new('A')
		content2 = ViewContent.new('B')
		content3 = ViewContent.new('B')
		
		content1.needs_rendering = false
		content2.needs_rendering = false
		content3.needs_rendering = false
		
		view1 = View.new('view1')
		
		assert_instance_of(ViewContent, view1.set_grid_cache(Point.new(0, 0), content1))
		assert_equal(true, content1.needs_rendering)
		
		assert_nil(view1.set_grid_cache(Point.new(0, 0), content1))
		assert_equal(true, content1.needs_rendering)
		
		assert_instance_of(ViewContent, view1.set_grid_cache(Point.new(0, 0), content2))
		assert_equal(true, content2.needs_rendering)
		
		assert_instance_of(ViewContent, view1.set_grid_cache(Point.new(0, 0), content3))
		assert_equal(true, content3.needs_rendering)
	end
	
	def test_render_simple
		view1 = View.new('view1')
		view1.is_visible = true
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		view1.draw_point([2, 0], 'C')
		
		rendered = view1.render
		
		assert_instance_of(Hash, rendered)
		assert_instance_of(Hash, rendered[0])
		assert_equal(1, rendered.count)
		assert_equal(3, rendered[0].count)
		assert_equal('A', rendered[0][0].char)
		assert_equal('B', rendered[0][1].char)
		assert_equal('C', rendered[0][2].char)
		
		
		rendered = view1.render
		
		assert_instance_of(Hash, rendered)
		assert_equal(0, rendered.count)
		
		
		view1.draw_point([3, 0], 'D')
		view1.draw_point([4, 0], 'E')
		
		rendered = view1.render
		
		assert_equal(1, rendered.count)
		assert_equal(2, rendered[0].count)
		assert_equal('D', rendered[0][3].char)
		assert_equal('E', rendered[0][4].char)
		
		
		rendered = view1.render
		
		assert_instance_of(Hash, rendered)
		assert_equal(0, rendered.count)
	end
	
	def test_render_subview_base
		view1 = View.new('view1')
		view1.is_visible = true
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		view1.draw_point([2, 0], 'C')
		
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = Point.new(2, 0)
		view2.draw_point([0, 0], 'D')
		
		view1.add_subview(view2)
		
		assert_equal(true, view1.grid[0][0].needs_rendering)
		assert_equal(true, view1.grid[0][1].needs_rendering)
		assert_equal(true, view1.grid[0][2].needs_rendering)
		
		rendered = view1.render
		
		assert_instance_of(Hash, rendered)
		assert_equal(1, rendered.count)
		assert_equal(3, rendered[0].count)
		
		assert_equal(false, view1.grid[0][0].needs_rendering)
		assert_equal(false, view1.grid[0][1].needs_rendering)
		assert_equal(true, view1.grid[0][2].needs_rendering)
		
		assert_equal('A', rendered[0][0].char)
		assert_equal('B', rendered[0][1].char)
		assert_equal('D', rendered[0][2].char)
		
		
		rendered = view1.render
		
		assert_instance_of(Hash, rendered)
		assert_equal(0, rendered.count)
		
		
		view2.draw_point([1, 0], 'E')
		
		rendered = view1.render
		
		assert_instance_of(Hash, rendered)
		assert_equal(1, rendered.count)
		assert_equal(1, rendered[0].count)
		assert_equal('E', rendered[0][3].char)
		
		
		# puts '-' * 30
		# puts '-' * 30
		# puts '-' * 30
		
		view2.is_visible = false
		
		# puts '-' * 30
		# puts '-' * 30
		# puts '-' * 30
		
		rendered = view1.render
		
		assert_instance_of(Hash, rendered)
		assert_equal(1, rendered.count)
		assert_equal(2, rendered[0].count)
		assert_equal('C', rendered[0][2].char)
		assert_equal(' ', rendered[0][3].char)
		
		
		rendered = view1.render
		
		assert_instance_of(Hash, rendered)
		assert_equal(0, rendered.count)
		
		
		
		# puts '-' * 30
		# puts '-' * 30
		# puts '-' * 30
		
		# pp view1.pp_grid_cache
	end
	
	def test_render_subview_chain1
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = Point.new(3, 0)
		
		view3 = View.new('view3')
		view3.is_visible = true
		view3.position = Point.new(4, 0)
		
		view1.add_subview(view2)
		view2.add_subview(view3)
		
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		
		view2.draw_point([0, 0], 'C')
		view2.draw_point([1, 0], 'D')
		
		view3.draw_point([0, 0], 'E')
		view3.draw_point([1, 0], 'F')
		
		rendered = view1.render
		
		assert_instance_of(Hash, rendered)
		assert_equal(1, rendered.count)
		assert_equal(6, rendered[0].count)
		assert_equal('A', rendered[0][0].char)
		assert_equal('B', rendered[0][1].char)
		assert_equal('C', rendered[0][3].char)
		assert_equal('D', rendered[0][4].char)
		assert_equal('E', rendered[0][7].char)
		assert_equal('F', rendered[0][8].char)
		
		# puts '-' * 30
		# puts '-' * 30
		# puts '-' * 30
		
		view3.is_visible = false
		
		# puts '-' * 30
		# puts '-' * 30
		# puts '-' * 30
		
		rendered = view1.render
		
		
		assert_equal(' ', rendered[0][7].char)
		assert_equal(' ', rendered[0][8].char)
		
		
		rendered = view1.render
		
		assert_instance_of(Hash, rendered)
		assert_equal(0, rendered.count)
		
		
		
		# pp view1.pp_grid_cache
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
	end
	
	def test_render_subview_chain2
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = Point.new(2, 0)
		
		view3 = View.new('view3')
		view3.is_visible = true
		view3.position = Point.new(2, 0)
		
		view1.add_subview(view2)
		view2.add_subview(view3)
		
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		
		view2.draw_point([0, 0], 'C')
		view2.draw_point([1, 0], 'D')
		
		view3.draw_point([0, 0], 'E')
		view3.draw_point([1, 0], 'F')
		
		rendered = view1.render
		
		# puts '-' * 30
		# puts '-' * 30
		# puts '-' * 30
		
		view2.is_visible = false
		
		# puts '-' * 30
		# puts '-' * 30
		# puts '-' * 30
		
		rendered = view1.render
		
		assert_equal(' ', rendered[0][2].char)
		assert_equal(' ', rendered[0][3].char)
		assert_equal(' ', rendered[0][4].char)
		assert_equal(' ', rendered[0][5].char)
		
		
		rendered = view1.render
		
		assert_equal(0, rendered.count)
		
		
		view2.is_visible = true
		
		rendered = view1.render
		
		assert_equal('C', rendered[0][2].char)
		assert_equal('D', rendered[0][3].char)
		assert_equal('E', rendered[0][4].char)
		assert_equal('F', rendered[0][5].char)
		
		
		# pp view1.pp_grid_cache
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
	end
	
	def test_render_subview_chain3
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = Point.new(2, 0)
		
		view3 = View.new('view3')
		view3.is_visible = true
		view3.position = Point.new(2, 0)
		view3.zindex = 10
		
		view4 = View.new('view4')
		view4.is_visible = true
		view4.position = Point.new(2, 0)
		view4.zindex = 20
		
		view1.add_subview(view2)
		view2.add_subview(view3)
		view2.add_subview(view4)
		
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		
		view2.draw_point([0, 0], 'C')
		view2.draw_point([1, 0], 'D')
		
		view3.draw_point([0, 0], 'E')
		view3.draw_point([1, 0], 'F')
		
		view4.draw_point([1, 0], 'G')
		
		rendered = view1.render
		
		# puts '-' * 30
		# puts '-' * 30
		# puts '-' * 30
		
		view2.is_visible = false
		
		# puts '-' * 30
		# puts '-' * 30
		# puts '-' * 30
		
		rendered = view1.render
		
		assert_equal(' ', rendered[0][2].char)
		assert_equal(' ', rendered[0][3].char)
		assert_equal(' ', rendered[0][4].char)
		assert_equal(' ', rendered[0][5].char)
		
		
		rendered = view1.render
		
		assert_equal(0, rendered.count)
		
		
		view2.is_visible = true
		
		rendered = view1.render
		
		
		assert_equal('C', rendered[0][2].char)
		assert_equal('D', rendered[0][3].char)
		assert_equal('E', rendered[0][4].char)
		assert_equal('G', rendered[0][5].char)
		
		
		view4.is_visible = false
		
		rendered = view1.render
		
		assert_equal('F', rendered[0][5].char)
		
		
		# pp view1.pp_grid_cache
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
	end
	
	def test_render_area_base1
		view1 = View.new('view1')
		view1.is_visible = true
		
		rendered = view1.render
		assert_instance_of(Hash, rendered)
		assert_equal(0, rendered.count)
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		view1.draw_point([2, 0], 'C')
		view1.draw_point([3, 0], 'D')
		
		view1.draw_point([0, 1], 'B')
		view1.draw_point([1, 1], 'C')
		view1.draw_point([2, 1], 'D')
		view1.draw_point([3, 1], 'E')
		
		view1.draw_point([0, 2], 'C')
		view1.draw_point([1, 2], 'D')
		view1.draw_point([2, 2], 'E')
		view1.draw_point([3, 2], 'F')
		
		view1.draw_point([0, 3], 'D')
		view1.draw_point([1, 3], 'E')
		view1.draw_point([2, 3], 'F')
		view1.draw_point([3, 3], 'G')
		
		
		rendered = view1.render(Rect.new(0, 0))
		
		assert_equal(4, rendered.count)
		assert_equal(4, rendered[0].count)
		assert_equal(4, rendered[1].count)
		assert_equal(4, rendered[2].count)
		assert_equal(4, rendered[3].count)
		
		assert_equal('A', rendered[0][0].char)
		assert_equal('B', rendered[0][1].char)
		assert_equal('C', rendered[0][2].char)
		assert_equal('D', rendered[0][3].char)
		
		assert_equal('B', rendered[1][0].char)
		assert_equal('C', rendered[1][1].char)
		assert_equal('D', rendered[1][2].char)
		assert_equal('E', rendered[1][3].char)
		
		assert_equal('C', rendered[2][0].char)
		assert_equal('D', rendered[2][1].char)
		assert_equal('E', rendered[2][2].char)
		assert_equal('F', rendered[2][3].char)
		
		assert_equal('D', rendered[3][0].char)
		assert_equal('E', rendered[3][1].char)
		assert_equal('F', rendered[3][2].char)
		assert_equal('G', rendered[3][3].char)
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
	end
	
	def test_render_area_base2
		view1 = View.new('view1')
		view1.is_visible = true
		
		rendered = view1.render
		assert_instance_of(Hash, rendered)
		assert_equal(0, rendered.count)
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		view1.draw_point([2, 0], 'C')
		view1.draw_point([3, 0], 'D')
		
		view1.draw_point([0, 1], 'B')
		view1.draw_point([1, 1], 'C')
		view1.draw_point([2, 1], 'D')
		view1.draw_point([3, 1], 'E')
		
		view1.draw_point([0, 2], 'C')
		view1.draw_point([1, 2], 'D')
		view1.draw_point([2, 2], 'E')
		view1.draw_point([3, 2], 'F')
		
		view1.draw_point([0, 3], 'D')
		view1.draw_point([1, 3], 'E')
		view1.draw_point([2, 3], 'F')
		view1.draw_point([3, 3], 'G')
		
		
		rendered = view1.render(Rect.new(1, 2))
		
		assert_equal(2, rendered.count)
		assert_nil(rendered[0])
		assert_nil(rendered[1])
		assert_equal(3, rendered[2].count)
		assert_equal(3, rendered[3].count)
		
		# assert_equal('A', rendered[0][0].char)
		# assert_equal('B', rendered[0][1].char)
		# assert_equal('C', rendered[0][2].char)
		# assert_equal('D', rendered[0][3].char)
		
		# assert_equal('B', rendered[1][0].char)
		# assert_equal('C', rendered[1][1].char)
		# assert_equal('D', rendered[1][2].char)
		# assert_equal('E', rendered[1][3].char)
		
		# assert_equal('C', rendered[2][0].char)
		assert_equal('D', rendered[2][1].char)
		assert_equal('E', rendered[2][2].char)
		assert_equal('F', rendered[2][3].char)
		
		# assert_equal('D', rendered[3][0].char)
		assert_equal('E', rendered[3][1].char)
		assert_equal('F', rendered[3][2].char)
		assert_equal('G', rendered[3][3].char)
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
	end
	
	def test_render_area_base3
		view1 = View.new('view1')
		view1.is_visible = true
		
		rendered = view1.render
		assert_instance_of(Hash, rendered)
		assert_equal(0, rendered.count)
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		view1.draw_point([2, 0], 'C')
		view1.draw_point([3, 0], 'D')
		
		view1.draw_point([0, 1], 'B')
		view1.draw_point([1, 1], 'C')
		view1.draw_point([2, 1], 'D')
		view1.draw_point([3, 1], 'E')
		
		view1.draw_point([0, 2], 'C')
		view1.draw_point([1, 2], 'D')
		view1.draw_point([2, 2], 'E')
		view1.draw_point([3, 2], 'F')
		
		view1.draw_point([0, 3], 'D')
		view1.draw_point([1, 3], 'E')
		view1.draw_point([2, 3], 'F')
		view1.draw_point([3, 3], 'G')
		
		
		rendered = view1.render(Rect.new(1, 2, 2, 1))
		
		assert_equal(1, rendered.count)
		assert_nil(rendered[0])
		assert_nil(rendered[1])
		assert_equal(2, rendered[2].count)
		assert_nil(rendered[3])
		
		# assert_equal('A', rendered[0][0].char)
		# assert_equal('B', rendered[0][1].char)
		# assert_equal('C', rendered[0][2].char)
		# assert_equal('D', rendered[0][3].char)
		
		# assert_equal('B', rendered[1][0].char)
		# assert_equal('C', rendered[1][1].char)
		# assert_equal('D', rendered[1][2].char)
		# assert_equal('E', rendered[1][3].char)
		
		# assert_equal('C', rendered[2][0].char)
		assert_equal('D', rendered[2][1].char)
		assert_equal('E', rendered[2][2].char)
		# assert_equal('F', rendered[2][3].char)
		
		# assert_equal('D', rendered[3][0].char)
		# assert_equal('E', rendered[3][1].char)
		# assert_equal('F', rendered[3][2].char)
		# assert_equal('G', rendered[3][3].char)
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
	end
	
	def test_render_area_base4
		view1 = View.new('view1')
		view1.is_visible = true
		
		rendered = view1.render
		assert_instance_of(Hash, rendered)
		assert_equal(0, rendered.count)
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		view1.draw_point([2, 0], 'C')
		view1.draw_point([3, 0], 'D')
		
		view1.draw_point([0, 1], 'B')
		view1.draw_point([1, 1], 'C')
		view1.draw_point([2, 1], 'D')
		view1.draw_point([3, 1], 'E')
		
		view1.draw_point([0, 2], 'C')
		view1.draw_point([1, 2], 'D')
		view1.draw_point([2, 2], 'E')
		view1.draw_point([3, 2], 'F')
		
		view1.draw_point([0, 3], 'D')
		view1.draw_point([1, 3], 'E')
		view1.draw_point([2, 3], 'F')
		view1.draw_point([3, 3], 'G')
		
		
		rendered = view1.render(Rect.new(0, 0, 1, 1))
		
		assert_equal(1, rendered.count)
		assert_equal(1, rendered[0].count)
		assert_nil(rendered[1])
		assert_nil(rendered[2])
		assert_nil(rendered[3])
		
		assert_equal('A', rendered[0][0].char)
		# assert_equal('B', rendered[0][1].char)
		# assert_equal('C', rendered[0][2].char)
		# assert_equal('D', rendered[0][3].char)
		
		# assert_equal('B', rendered[1][0].char)
		# assert_equal('C', rendered[1][1].char)
		# assert_equal('D', rendered[1][2].char)
		# assert_equal('E', rendered[1][3].char)
		
		# assert_equal('C', rendered[2][0].char)
		# assert_equal('D', rendered[2][1].char)
		# assert_equal('E', rendered[2][2].char)
		# assert_equal('F', rendered[2][3].char)
		
		# assert_equal('D', rendered[3][0].char)
		# assert_equal('E', rendered[3][1].char)
		# assert_equal('F', rendered[3][2].char)
		# assert_equal('G', rendered[3][3].char)
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
	end
	
	def test_render_area_base5
		view1 = View.new('view1')
		view1.is_visible = true
		
		rendered = view1.render
		assert_instance_of(Hash, rendered)
		assert_equal(0, rendered.count)
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		view1.draw_point([2, 0], 'C')
		view1.draw_point([3, 0], 'D')
		
		view1.draw_point([0, 1], 'B')
		view1.draw_point([1, 1], 'C')
		view1.draw_point([2, 1], 'D')
		view1.draw_point([3, 1], 'E')
		
		view1.draw_point([0, 2], 'C')
		view1.draw_point([1, 2], 'D')
		view1.draw_point([2, 2], 'E')
		view1.draw_point([3, 2], 'F')
		
		view1.draw_point([0, 3], 'D')
		view1.draw_point([1, 3], 'E')
		view1.draw_point([2, 3], 'F')
		view1.draw_point([3, 3], 'G')
		
		
		rendered = view1.render(Rect.new(1, 1, 2, 2))
		
		assert_equal(2, rendered.count)
		assert_nil(rendered[0])
		assert_equal(2, rendered[1].count)
		assert_equal(2, rendered[2].count)
		assert_nil(rendered[3])
		
		# assert_equal('A', rendered[0][0].char)
		# assert_equal('B', rendered[0][1].char)
		# assert_equal('C', rendered[0][2].char)
		# assert_equal('D', rendered[0][3].char)
		
		# assert_equal('B', rendered[1][0].char)
		assert_equal('C', rendered[1][1].char)
		assert_equal('D', rendered[1][2].char)
		# assert_equal('E', rendered[1][3].char)
		
		# assert_equal('C', rendered[2][0].char)
		assert_equal('D', rendered[2][1].char)
		assert_equal('E', rendered[2][2].char)
		# assert_equal('F', rendered[2][3].char)
		
		# assert_equal('D', rendered[3][0].char)
		# assert_equal('E', rendered[3][1].char)
		# assert_equal('F', rendered[3][2].char)
		# assert_equal('G', rendered[3][3].char)
		
		
		rendered = view1.render(Rect.new(2, 2))
		
		assert_equal(2, rendered.count)
		assert_nil(rendered[0])
		assert_nil(rendered[1])
		assert_equal(1, rendered[2].count)
		assert_equal(2, rendered[3].count)
		
		# assert_equal('A', rendered[0][0].char)
		# assert_equal('B', rendered[0][1].char)
		# assert_equal('C', rendered[0][2].char)
		# assert_equal('D', rendered[0][3].char)
		
		# assert_equal('B', rendered[1][0].char)
		# assert_equal('C', rendered[1][1].char)
		# assert_equal('D', rendered[1][2].char)
		# assert_equal('E', rendered[1][3].char)
		
		# assert_equal('C', rendered[2][0].char)
		# assert_equal('D', rendered[2][1].char)
		assert_nil(rendered[2][2])
		assert_equal('F', rendered[2][3].char)
		
		# assert_equal('D', rendered[3][0].char)
		# assert_equal('E', rendered[3][1].char)
		assert_equal('F', rendered[3][2].char)
		assert_equal('G', rendered[3][3].char)
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
	end
	
	def test_render_area_size1
		view1 = View.new('view1')
		view1.is_visible = true
		view1.size = Size.new(3, 2)
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		view1.draw_point([2, 0], 'C')
		view1.draw_point([3, 0], 'D')
		
		view1.draw_point([0, 1], 'B')
		view1.draw_point([1, 1], 'C')
		view1.draw_point([2, 1], 'D')
		view1.draw_point([3, 1], 'E')
		
		view1.draw_point([0, 2], 'C')
		view1.draw_point([1, 2], 'D')
		view1.draw_point([2, 2], 'E')
		view1.draw_point([3, 2], 'F')
		
		view1.draw_point([0, 3], 'D')
		view1.draw_point([1, 3], 'E')
		view1.draw_point([2, 3], 'F')
		view1.draw_point([3, 3], 'G')
		
		
		rendered = view1.render
		
		assert_equal(2, rendered.count)
		assert_equal(3, rendered[0].count)
		assert_equal(3, rendered[1].count)
		# assert_equal(4, rendered[2].count)
		# assert_equal(4, rendered[3].count)
		
		assert_equal('A', rendered[0][0].char)
		assert_equal('B', rendered[0][1].char)
		assert_equal('C', rendered[0][2].char)
		# assert_equal('D', rendered[0][3].char)
		
		assert_equal('B', rendered[1][0].char)
		assert_equal('C', rendered[1][1].char)
		assert_equal('D', rendered[1][2].char)
		# assert_equal('E', rendered[1][3].char)
		
		# assert_equal('C', rendered[2][0].char)
		# assert_equal('D', rendered[2][1].char)
		# assert_equal('E', rendered[2][2].char)
		# assert_equal('F', rendered[2][3].char)
		
		# assert_equal('D', rendered[3][0].char)
		# assert_equal('E', rendered[3][1].char)
		# assert_equal('F', rendered[3][2].char)
		# assert_equal('G', rendered[3][3].char)
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
	end
	
	def test_render_area_size2
		view1 = View.new('view1')
		view1.is_visible = true
		view1.size = Size.new(3, 1)
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		view1.draw_point([2, 0], 'C')
		view1.draw_point([3, 0], 'D')
		
		view1.draw_point([0, 1], 'B')
		view1.draw_point([1, 1], 'C')
		view1.draw_point([2, 1], 'D')
		view1.draw_point([3, 1], 'E')
		
		view1.draw_point([0, 2], 'C')
		view1.draw_point([1, 2], 'D')
		view1.draw_point([2, 2], 'E')
		view1.draw_point([3, 2], 'F')
		
		view1.draw_point([0, 3], 'D')
		view1.draw_point([1, 3], 'E')
		view1.draw_point([2, 3], 'F')
		view1.draw_point([3, 3], 'G')
		
		
		rendered = view1.render(Rect.new(1, 1, 2, 2))
		
		assert_equal(2, rendered.count)
		# assert_equal(3, rendered[0].count)
		assert_equal(2, rendered[1].count)
		assert_equal(2, rendered[2].count)
		# assert_equal(4, rendered[3].count)
		
		# assert_equal('A', rendered[0][0].char)
		# assert_equal('B', rendered[0][1].char)
		# assert_equal('C', rendered[0][2].char)
		# assert_equal('D', rendered[0][3].char)
		
		# assert_equal('B', rendered[1][0].char)
		assert_equal('C', rendered[1][1].char)
		assert_equal('D', rendered[1][2].char)
		# assert_equal('E', rendered[1][3].char)
		
		# assert_equal('C', rendered[2][0].char)
		assert_equal('D', rendered[2][1].char)
		assert_equal('E', rendered[2][2].char)
		# assert_equal('F', rendered[2][3].char)
		
		# assert_equal('D', rendered[3][0].char)
		# assert_equal('E', rendered[3][1].char)
		# assert_equal('F', rendered[3][2].char)
		# assert_equal('G', rendered[3][3].char)
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
	end
	
	def test_render_area_subview1
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = Point.new(1, 1)
		# view2.zindex = 10
		view1.add_subview(view2)
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		view1.draw_point([2, 0], 'C')
		view1.draw_point([3, 0], 'D')
		
		view1.draw_point([0, 1], 'B')
		view1.draw_point([1, 1], 'C')
		view1.draw_point([2, 1], 'D')
		view1.draw_point([3, 1], 'E')
		
		view1.draw_point([0, 2], 'C')
		view1.draw_point([1, 2], 'D')
		view1.draw_point([2, 2], 'E')
		view1.draw_point([3, 2], 'F')
		
		view1.draw_point([0, 3], 'D')
		view1.draw_point([1, 3], 'E')
		view1.draw_point([2, 3], 'F')
		view1.draw_point([3, 3], 'G')
		
		
		view2.draw_point([0, 0], 'a')
		view2.draw_point([1, 0], 'b')
		view2.draw_point([2, 0], 'c')
		
		view2.draw_point([0, 1], 'b')
		view2.draw_point([1, 1], 'c')
		view2.draw_point([2, 1], 'd')
		
		view2.draw_point([0, 2], 'c')
		view2.draw_point([1, 2], 'd')
		view2.draw_point([2, 2], 'e')
		
		
		rendered = view1.render(Rect.new(0, 0))
		# rendered = view2.render(Rect.new(0, 0))
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
		
		assert_equal(4, rendered.count)
		assert_equal(4, rendered[0].count)
		assert_equal(4, rendered[1].count)
		assert_equal(4, rendered[2].count)
		assert_equal(4, rendered[3].count)
		
		assert_equal('A', rendered[0][0].char)
		assert_equal('B', rendered[0][1].char)
		assert_equal('C', rendered[0][2].char)
		assert_equal('D', rendered[0][3].char)
		
		assert_equal('B', rendered[1][0].char)
		assert_equal('a', rendered[1][1].char)
		assert_equal('b', rendered[1][2].char)
		assert_equal('c', rendered[1][3].char)
		
		assert_equal('C', rendered[2][0].char)
		assert_equal('b', rendered[2][1].char)
		assert_equal('c', rendered[2][2].char)
		assert_equal('d', rendered[2][3].char)
		
		assert_equal('D', rendered[3][0].char)
		assert_equal('c', rendered[3][1].char)
		assert_equal('d', rendered[3][2].char)
		assert_equal('e', rendered[3][3].char)
	end
	
	def test_render_area_subview2
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = Point.new(1, 1)
		# view2.zindex = 10
		view1.add_subview(view2)
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		view1.draw_point([2, 0], 'C')
		view1.draw_point([3, 0], 'D')
		
		view1.draw_point([0, 1], 'B')
		view1.draw_point([1, 1], 'C')
		view1.draw_point([2, 1], 'D')
		view1.draw_point([3, 1], 'E')
		
		view1.draw_point([0, 2], 'C')
		view1.draw_point([1, 2], 'D')
		view1.draw_point([2, 2], 'E')
		view1.draw_point([3, 2], 'F')
		
		view1.draw_point([0, 3], 'D')
		view1.draw_point([1, 3], 'E')
		view1.draw_point([2, 3], 'F')
		view1.draw_point([3, 3], 'G')
		
		
		view2.draw_point([0, 0], 'a')
		view2.draw_point([1, 0], 'b')
		view2.draw_point([2, 0], 'c')
		
		view2.draw_point([0, 1], 'b')
		view2.draw_point([1, 1], 'c')
		view2.draw_point([2, 1], 'd')
		
		view2.draw_point([0, 2], 'c')
		view2.draw_point([1, 2], 'd')
		view2.draw_point([2, 2], 'e')
		
		
		rendered = view1.render(Rect.new(1, 0, 3, 2))
		# rendered = view2.render(Rect.new(0, 0))
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
		
		assert_equal(2, rendered.count)
		assert_equal(3, rendered[0].count)
		assert_equal(3, rendered[1].count)
		assert_nil(rendered[2])
		assert_nil(rendered[3])
		
		# assert_equal('A', rendered[0][0].char)
		assert_equal('B', rendered[0][1].char)
		assert_equal('C', rendered[0][2].char)
		assert_equal('D', rendered[0][3].char)
		
		# assert_equal('B', rendered[1][0].char)
		assert_equal('a', rendered[1][1].char)
		assert_equal('b', rendered[1][2].char)
		assert_equal('c', rendered[1][3].char)
		
		# assert_equal('C', rendered[2][0].char)
		# assert_equal('b', rendered[2][1].char)
		# assert_equal('c', rendered[2][2].char)
		# assert_equal('d', rendered[2][3].char)
		
		# assert_equal('D', rendered[3][0].char)
		# assert_equal('c', rendered[3][1].char)
		# assert_equal('d', rendered[3][2].char)
		# assert_equal('e', rendered[3][3].char)
		
		
		rendered = view1.render(Rect.new(0, 1, nil, 2))
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
		
		assert_equal(2, rendered.count)
		assert_nil(rendered[0])
		assert_equal(1, rendered[1].count)
		assert_equal(4, rendered[2].count)
		assert_nil(rendered[3])
		
		# assert_equal('A', rendered[0][0].char)
		# assert_equal('B', rendered[0][1].char)
		# assert_equal('C', rendered[0][2].char)
		# assert_equal('D', rendered[0][3].char)
		
		assert_equal('B', rendered[1][0].char)
		# assert_equal('a', rendered[1][1].char)
		# assert_equal('b', rendered[1][2].char)
		# assert_equal('c', rendered[1][3].char)
		
		assert_equal('C', rendered[2][0].char)
		assert_equal('b', rendered[2][1].char)
		assert_equal('c', rendered[2][2].char)
		assert_equal('d', rendered[2][3].char)
		
		# assert_equal('D', rendered[3][0].char)
		# assert_equal('c', rendered[3][1].char)
		# assert_equal('d', rendered[3][2].char)
		# assert_equal('e', rendered[3][3].char)
	end
	
	def test_render_area_subview3
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = Point.new(1, 1)
		# view2.zindex = 10
		view1.add_subview(view2)
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		view1.draw_point([2, 0], 'C')
		view1.draw_point([3, 0], 'D')
		
		view1.draw_point([0, 1], 'B')
		view1.draw_point([1, 1], 'C')
		view1.draw_point([2, 1], 'D')
		view1.draw_point([3, 1], 'E')
		
		view1.draw_point([0, 2], 'C')
		view1.draw_point([1, 2], 'D')
		view1.draw_point([2, 2], 'E')
		view1.draw_point([3, 2], 'F')
		
		view1.draw_point([0, 3], 'D')
		view1.draw_point([1, 3], 'E')
		view1.draw_point([2, 3], 'F')
		view1.draw_point([3, 3], 'G')
		
		
		view2.draw_point([0, 0], 'a')
		view2.draw_point([1, 0], 'b')
		view2.draw_point([2, 0], 'c')
		
		view2.draw_point([0, 1], 'b')
		view2.draw_point([1, 1], 'c')
		view2.draw_point([2, 1], 'd')
		
		view2.draw_point([0, 2], 'c')
		view2.draw_point([1, 2], 'd')
		view2.draw_point([2, 2], 'e')
		
		
		rendered = view1.render(Rect.new(1, 0, 2, nil))
		# rendered = view2.render(Rect.new(0, 0))
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
		
		assert_equal(4, rendered.count)
		assert_equal(2, rendered[0].count)
		assert_equal(2, rendered[1].count)
		assert_equal(2, rendered[2].count)
		assert_equal(2, rendered[3].count)
		
		# assert_equal('A', rendered[0][0].char)
		assert_equal('B', rendered[0][1].char)
		assert_equal('C', rendered[0][2].char)
		# assert_equal('D', rendered[0][3].char)
		
		# assert_equal('B', rendered[1][0].char)
		assert_equal('a', rendered[1][1].char)
		assert_equal('b', rendered[1][2].char)
		# assert_equal('c', rendered[1][3].char)
		
		# assert_equal('C', rendered[2][0].char)
		assert_equal('b', rendered[2][1].char)
		assert_equal('c', rendered[2][2].char)
		# assert_equal('d', rendered[2][3].char)
		
		# assert_equal('D', rendered[3][0].char)
		assert_equal('c', rendered[3][1].char)
		assert_equal('d', rendered[3][2].char)
		# assert_equal('e', rendered[3][3].char)
		
		
		rendered = view1.render(Rect.new(0, 1, nil, 2))
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
		
		assert_equal(2, rendered.count)
		assert_nil(rendered[0])
		assert_equal(2, rendered[1].count)
		assert_equal(2, rendered[2].count)
		assert_nil(rendered[3])
		
		# assert_equal('A', rendered[0][0].char)
		# assert_equal('B', rendered[0][1].char)
		# assert_equal('C', rendered[0][2].char)
		# assert_equal('D', rendered[0][3].char)
		
		assert_equal('B', rendered[1][0].char)
		# assert_equal('a', rendered[1][1].char)
		# assert_equal('b', rendered[1][2].char)
		assert_equal('c', rendered[1][3].char)
		
		assert_equal('C', rendered[2][0].char)
		# assert_equal('b', rendered[2][1].char)
		# assert_equal('c', rendered[2][2].char)
		assert_equal('d', rendered[2][3].char)
		
		# assert_equal('D', rendered[3][0].char)
		# assert_equal('c', rendered[3][1].char)
		# assert_equal('d', rendered[3][2].char)
		# assert_equal('e', rendered[3][3].char)
		
		
		rendered = view1.render
		
		# pp rendered.map{ |y, row| row.map{ |x, content| "#{x}:#{y}=>'#{content.char}'" } }.flatten
		
		assert_equal(2, rendered.count)
		assert_equal(2, rendered[0].count)
		assert_nil(rendered[1])
		assert_nil(rendered[2])
		assert_equal(2, rendered[3].count)
		
		
		assert_equal('A', rendered[0][0].char)
		# assert_equal('B', rendered[0][1].char)
		# assert_equal('C', rendered[0][2].char)
		assert_equal('D', rendered[0][3].char)
		
		# assert_equal('B', rendered[1][0].char)
		# assert_equal('a', rendered[1][1].char)
		# assert_equal('b', rendered[1][2].char)
		# assert_equal('c', rendered[1][3].char)
		
		# assert_equal('C', rendered[2][0].char)
		# assert_equal('b', rendered[2][1].char)
		# assert_equal('c', rendered[2][2].char)
		# assert_equal('d', rendered[2][3].char)
		
		assert_equal('D', rendered[3][0].char)
		# assert_equal('c', rendered[3][1].char)
		# assert_equal('d', rendered[3][2].char)
		assert_equal('e', rendered[3][3].char)
	end
	
	def test_render_position1
		view1 = View.new('view1')
		view1.is_visible = true
		view1.zindex = 20
		view1.position = Point.new(0, 0)
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		view1.draw_point([2, 0], 'C')
		view1.draw_point([1, 1], 'b')
		
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.zindex = 10
		view2.position = Point.new(0, 1)
		
		view2.draw_point([0, 0], 'D')
		view2.draw_point([1, 0], 'E')
		view2.draw_point([2, 0], 'F')
		
		
		view3 = View.new('view3')
		view3.is_visible = true
		view3.add_subview(view1)
		view3.add_subview(view2)
		
		rendered = view3.render
		
		assert_equal(2, rendered.count)
		assert_equal('A', rendered[0][0].char)
		assert_equal('B', rendered[0][1].char)
		assert_equal('C', rendered[0][2].char)
		assert_equal('D', rendered[1][0].char)
		assert_equal('b', rendered[1][1].char)
		assert_equal('F', rendered[1][2].char)
		
		
		# puts
		# puts %(--- set new position BEGIN ---)
		view2.position = Point.new(1, 1)
		# puts %(--- set new position END   ---)
		
		rendered = view3.render
		
		assert_equal(1, rendered.count)
		assert_equal(' ', rendered[1][0].char)
		assert_equal('E', rendered[1][2].char)
		assert_equal('F', rendered[1][3].char)
		assert_instance_of(ClearViewContent, rendered[1][0])
		
		# pp rendered
	end
	
	def test_render_position2
		view1 = View.new('view1')
		view1.is_visible = true
		view1.zindex = 10
		view1.position = Point.new(0, 0)
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		view1.draw_point([2, 0], 'C')
		view1.draw_point([3, 0], 'D')
		view1.draw_point([4, 0], 'E')
		view1.draw_point([5, 0], 'F')
		
		view1.draw_point([0, 1], 'B')
		view1.draw_point([1, 1], 'C')
		view1.draw_point([2, 1], 'D')
		view1.draw_point([3, 1], 'E')
		view1.draw_point([4, 1], 'F')
		view1.draw_point([5, 1], 'G')
		
		view1.draw_point([0, 2], 'C')
		view1.draw_point([1, 2], 'D')
		view1.draw_point([2, 2], 'E')
		view1.draw_point([3, 2], 'F')
		view1.draw_point([4, 2], 'G')
		view1.draw_point([5, 2], 'H')
		
		view1.draw_point([0, 3], 'D')
		view1.draw_point([1, 3], 'E')
		view1.draw_point([2, 3], 'F')
		view1.draw_point([3, 3], 'G')
		view1.draw_point([4, 3], 'H')
		view1.draw_point([5, 3], 'I')
		
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.zindex = 20
		view2.position = Point.new(0, 0)
		
		view2.draw_point([0, 0], 'a')
		view2.draw_point([1, 0], 'b')
		view2.draw_point([2, 0], 'c')
		view2.draw_point([3, 0], 'd')
		
		view2.draw_point([0, 1], 'b')
		view2.draw_point([1, 1], 'c')
		view2.draw_point([2, 1], 'd')
		view2.draw_point([3, 1], 'e')
		
		view2.draw_point([0, 2], 'c')
		view2.draw_point([1, 2], 'd')
		view2.draw_point([2, 2], 'e')
		view2.draw_point([3, 2], 'f')
		
		view2.draw_point([0, 3], 'd')
		view2.draw_point([1, 3], 'e')
		view2.draw_point([2, 3], 'f')
		view2.draw_point([3, 3], 'g')
		
		
		view3 = View.new('view3')
		view3.is_visible = true
		view3.add_subview(view1)
		view3.add_subview(view2)
		
		rendered = view3.render
		
		assert_equal(4, rendered.count)
		
		assert_equal('a', rendered[0][0].char)
		assert_equal('b', rendered[0][1].char)
		assert_equal('c', rendered[0][2].char)
		assert_equal('d', rendered[0][3].char)
		assert_equal('E', rendered[0][4].char)
		assert_equal('F', rendered[0][5].char)
		
		assert_equal('b', rendered[1][0].char)
		assert_equal('c', rendered[1][1].char)
		assert_equal('d', rendered[1][2].char)
		assert_equal('e', rendered[1][3].char)
		assert_equal('F', rendered[1][4].char)
		assert_equal('G', rendered[1][5].char)
		
		assert_equal('c', rendered[2][0].char)
		assert_equal('d', rendered[2][1].char)
		assert_equal('e', rendered[2][2].char)
		assert_equal('f', rendered[2][3].char)
		assert_equal('G', rendered[2][4].char)
		assert_equal('H', rendered[2][5].char)
		
		assert_equal('d', rendered[3][0].char)
		assert_equal('e', rendered[3][1].char)
		assert_equal('f', rendered[3][2].char)
		assert_equal('g', rendered[3][3].char)
		assert_equal('H', rendered[3][4].char)
		assert_equal('I', rendered[3][5].char)
		
		
		view2.position = Point.new(3, 2)
		rendered = view3.render
		
		assert_equal(6, rendered.count)
		assert_equal(4, rendered[0].count)
		assert_equal(4, rendered[1].count)
		assert_equal(7, rendered[2].count)
		assert_equal(7, rendered[3].count)
		assert_equal(4, rendered[4].count)
		assert_equal(4, rendered[5].count)
		
		assert_equal('A', rendered[0][0].char)
		assert_equal('B', rendered[0][1].char)
		assert_equal('C', rendered[0][2].char)
		assert_equal('D', rendered[0][3].char)
		
		assert_equal('B', rendered[1][0].char)
		assert_equal('C', rendered[1][1].char)
		assert_equal('D', rendered[1][2].char)
		assert_equal('E', rendered[1][3].char)
		
		assert_equal('C', rendered[2][0].char)
		assert_equal('D', rendered[2][1].char)
		assert_equal('E', rendered[2][2].char)
		assert_equal('a', rendered[2][3].char)
		assert_equal('b', rendered[2][4].char)
		assert_equal('c', rendered[2][5].char)
		assert_equal('d', rendered[2][6].char)
		
		assert_equal('D', rendered[3][0].char)
		assert_equal('E', rendered[3][1].char)
		assert_equal('F', rendered[3][2].char)
		assert_equal('b', rendered[3][3].char)
		assert_equal('c', rendered[3][4].char)
		assert_equal('d', rendered[3][5].char)
		assert_equal('e', rendered[3][6].char)
		
		assert_equal('c', rendered[4][3].char)
		assert_equal('d', rendered[4][4].char)
		assert_equal('e', rendered[4][5].char)
		assert_equal('f', rendered[4][6].char)
		
		assert_equal('d', rendered[5][3].char)
		assert_equal('e', rendered[5][4].char)
		assert_equal('f', rendered[5][5].char)
		assert_equal('g', rendered[5][6].char)
		
		
		view2.position = Point.new(1, 1)
		rendered = view3.render
		
		assert_equal(5, rendered.count)
		assert_equal(4, rendered[1].count)
		assert_equal(6, rendered[2].count)
		assert_equal(6, rendered[3].count)
		assert_equal(6, rendered[4].count)
		assert_equal(4, rendered[5].count)
		
		assert_equal('a', rendered[1][1].char)
		assert_equal('b', rendered[1][2].char)
		assert_equal('c', rendered[1][3].char)
		assert_equal('d', rendered[1][4].char)
		
		assert_equal('b', rendered[2][1].char)
		assert_equal('c', rendered[2][2].char)
		assert_equal('d', rendered[2][3].char)
		assert_equal('e', rendered[2][4].char)
		assert_equal('H', rendered[2][5].char)
		assert_equal(' ', rendered[2][6].char)
		
		assert_equal('c', rendered[3][1].char)
		assert_equal('d', rendered[3][2].char)
		assert_equal('e', rendered[3][3].char)
		assert_equal('f', rendered[3][4].char)
		assert_equal('I', rendered[3][5].char)
		assert_equal(' ', rendered[3][6].char)
		
		assert_equal('d', rendered[4][1].char)
		assert_equal('e', rendered[4][2].char)
		assert_equal('f', rendered[4][3].char)
		assert_equal('g', rendered[4][4].char)
		assert_equal(' ', rendered[4][5].char)
		assert_equal(' ', rendered[4][6].char)
		
		assert_equal(' ', rendered[5][3].char)
		assert_equal(' ', rendered[5][4].char)
		assert_equal(' ', rendered[5][5].char)
		assert_equal(' ', rendered[5][6].char)
		
		# puts
		# pp rendered[5]
	end
	
	def test_render_position3
		view1 = View.new('view1')
		view1.is_visible = true
		view1.position = Point.new(3, 3)
		view1.draw_point([1, 5], 'A')
		view1.draw_point([3, 6], 'B')
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = Point.new(7, 7)
		view2.add_subview(view1)
		
		view3 = View.new('view3')
		view3.is_visible = true
		view3.add_subview(view2)
		
		
		rendered = view3.render
		# puts; pp rendered; puts
		
		assert_equal(2, rendered.count)
		assert_equal(1, rendered[15].count)
		assert_equal(1, rendered[16].count)
		assert_equal('A', rendered[15][11].char)
		assert_equal('B', rendered[16][13].char)
		
		# puts '-------- SET POS BEGIN --------'
		view1.position = Point.new(17, 17)
		# puts '-------- SET POS END ----------'
		# puts
		
		# puts '--- view1 ---'; pp view1.grid_cache; puts
		# puts '--- view2 ---'; pp view2.grid_cache; puts
		# puts '--- view3 ---'; pp view3.grid_cache; puts
		
		# puts '-------- RENDER --------'
		rendered = view3.render
		
		# puts; pp rendered; puts
		# puts '--- view1 ---'; pp view1.grid_cache; puts
		# puts '--- view2 ---'; pp view2.grid_cache; puts
		# puts '--- view3 ---'; pp view3.grid_cache; puts
		
		assert_equal(4, rendered.count)
		assert_equal(1, rendered[15].count)
		assert_equal(1, rendered[16].count)
		assert_equal(1, rendered[29].count)
		assert_equal(1, rendered[30].count)
		assert_equal(' ', rendered[15][11].char)
		assert_equal(' ', rendered[16][13].char)
		assert_equal('A', rendered[29][25].char)
		assert_equal('B', rendered[30][27].char)
	end
	
	def test_render_position4
		view1 = View.new('view1')
		view1.is_visible = true
		view1.position = Point.new(3, 5)
		view1.draw_point([1, 0], 'A')
		view1.draw_point([2, 0], 'B')
		content3 = view1.draw_point([3, 0], 'B')
		view1.draw_point([4, 0], 'C')
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = Point.new(7, 11)
		view2.add_subview(view1)
		
		view3 = View.new('view3')
		view3.is_visible = true
		view3.add_subview(view2)
		
		
		rendered = view3.render
		# puts; pp rendered; puts
		
		# pp view1.grid_cache
		# pp view2.grid_cache
		# pp view3.grid_cache
		
		puts '-------- SET POS BEGIN --------'
		view1.position = Point.new(4, 5)
		puts '-------- SET POS END ----------'
		puts
		
		pp view1.grid_cache.sort.to_h
		puts
		pp view2.grid_cache.sort.to_h
		puts
		pp view3.grid_cache.sort.to_h
		puts
		
		rendered = view3.render
		puts; pp rendered; puts
		
		# pp view1.grid_cache.sort.to_h
		# puts
		# pp view2.grid_cache.sort.to_h
		# puts
		# pp view3.grid_cache.sort.to_h
		# puts
		
		assert_equal(1, rendered.count)
		assert_equal(5, rendered[16].count)
		assert_equal(' ', rendered[16][11].char)
		assert_equal('A', rendered[16][12].char)
		assert_equal('B', rendered[16][13].char)
		assert_equal('B', rendered[16][14].char)
		assert_equal('C', rendered[16][15].char)
	end
	
	def test_render_position5
		view1 = View.new('view1')
		view1.is_visible = true
		view1.position = Point.new(3, 5)
		view1.draw_point([0, 1], 'A')
		view1.draw_point([0, 2], 'B')
		view1.draw_point([0, 3], 'B')
		view1.draw_point([0, 4], 'C')
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = Point.new(7, 11)
		view2.add_subview(view1)
		
		view3 = View.new('view3')
		view3.is_visible = true
		view3.add_subview(view2)
		
		
		rendered = view3.render
		# puts; pp rendered; puts
		
		# pp view1.grid_cache
		# pp view2.grid_cache
		# pp view3.grid_cache
		
		# puts '-------- SET POS BEGIN --------'
		view1.position = Point.new(3, 6)
		# puts '-------- SET POS END ----------'
		# puts
		
		# pp view1.grid_cache.sort.to_h
		# puts
		# pp view2.grid_cache.sort.to_h
		# puts
		# pp view3.grid_cache.sort.to_h
		# puts
		
		rendered = view3.render
		# puts; pp rendered; puts
		
		assert_equal(5, rendered.count)
		assert_equal(1, rendered[17].count)
		assert_equal(1, rendered[18].count)
		assert_equal(1, rendered[20].count)
		assert_equal(1, rendered[21].count)
		assert_equal(' ', rendered[17][10].char)
		assert_equal('A', rendered[18][10].char)
		assert_equal('B', rendered[19][10].char)
		assert_equal('B', rendered[20][10].char)
		assert_equal('C', rendered[21][10].char)
	end
	
	def test_render_position_negative
		view1 = View.new('view1')
		view1.is_visible = true
		view1.position = Point.new(0, -1)
		view1.draw_point([0, 0], 'A')
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = Point.new(0, -2)
		view2.draw_point([0, 0], 'B')
		
		view3 = View.new('view3')
		view3.is_visible = true
		view3.add_subview(view1)
		view3.add_subview(view2)
		
		rendered = view3.render
		puts; pp rendered; puts
		
		assert_equal(2, rendered.count)
		assert_equal(1, rendered[-1].count)
		assert_equal(1, rendered[-2].count)
	end
	
	def test_render_grid_cache_erase_point1
		view1 = View.new('view1')
		view1.is_visible = true
		view1.position = Point.new(0, 0)
		
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		view1.draw_point([2, 0], 'C')
		view1.draw_point([3, 0], 'D')
		view1.draw_point([4, 0], 'E')
		view1.draw_point([5, 0], 'F')
		
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.add_subview(view1)
		
		# puts '----- RENDER A ------'
		rendered = view2.render
		# puts; pp rendered; puts
		
		# puts '----- ERASE A ------'
		view1.grid_cache_erase_point(Point.new(0, 0))
		
		# puts '----- RENDER B ------'
		rendered = view2.render
		# puts; pp rendered; puts
		
		assert_equal(1, rendered.count)
		assert_equal(1, rendered[0].count)
		assert_equal('A', rendered[0][0].char)
		assert_instance_of(ViewContent, rendered[0][0])
		
		# puts '----- ERASE B ------'
		view2.grid_cache_erase_point(Point.new(0, 0))
		
		# puts '----- RENDER C ------'
		rendered = view2.render
		# puts; pp rendered; puts
		
		assert_equal(1, rendered.count)
		assert_equal(1, rendered[0].count)
		assert_equal('A', rendered[0][0].char)
		assert_instance_of(ViewContent, rendered[0][0])
		
		view1.grid_erase_point(Point.new(0, 0))
		
		rendered = view2.render
		# puts; pp rendered; puts
		
		assert_equal(1, rendered.count)
		assert_equal(1, rendered[0].count)
		assert_equal(' ', rendered[0][0].char)
		assert_instance_of(ClearViewContent, rendered[0][0])
	end
	
	def test_render_grid_cache_erase_point2
		view1 = View.new('view1')
		view1.is_visible = true
		view1.position = Point.new(3, 3)
		view1.draw_point([0, 0], 'A')
		view1.draw_point([1, 0], 'B')
		
		view2 = View.new('view2')
		view2.is_visible = true
		view2.position = Point.new(7, 7)
		view2.add_subview(view1)
		
		view3 = View.new('view3')
		view3.is_visible = true
		view3.position = Point.new(13, 13)
		view3.add_subview(view2)
		
		view4 = View.new('view4')
		view4.is_visible = true
		view4.add_subview(view3)
		
		view4.render
		
		assert_equal(1, view4.grid_cache.count)
		assert_equal(2, view4.grid_cache[23].count)
		assert_equal(1, view3.grid_cache.count)
		assert_equal(2, view3.grid_cache[10].count)
		assert_equal(1, view2.grid_cache.count)
		assert_equal(2, view2.grid_cache[3].count)
		assert_equal(1, view1.grid_cache.count)
		assert_equal(2, view1.grid_cache[0].count)
		
		view1.grid_erase_point(Point.new(1, 0))
		
		# puts '--- view1 ---'; pp view1.grid_cache
		# puts '--- view2 ---'; pp view2.grid_cache
		# puts '--- view3 ---'; pp view3.grid_cache
		# puts '--- view4 ---'; pp view4.grid_cache
		
		# puts
		view4.render
		# rendered = view4.render
		# puts; pp rendered; puts
		
		# puts '--- view1 ---'; pp view1.grid_cache
		# puts '--- view2 ---'; pp view2.grid_cache
		# puts '--- view3 ---'; pp view3.grid_cache
		# puts '--- view4 ---'; pp view4.grid_cache
		
		assert_equal(1, view4.grid_cache.count)
		assert_equal(1, view4.grid_cache[23].count)
		assert_equal(1, view3.grid_cache.count)
		assert_equal(1, view3.grid_cache[10].count)
		assert_equal(1, view2.grid_cache.count)
		assert_equal(1, view2.grid_cache[3].count)
		assert_equal(1, view1.grid_cache.count)
		assert_equal(1, view1.grid_cache[0].count)
	end
	
	def test_to_s
		view1 = View.new
		assert_nil(view1.to_s)
		
		view1 = View.new('view1')
		assert_equal('view1', view1.to_s)
	end
	
	def test_inspect
		view1 = View.new
		assert_equal('#<View name= w=0>', view1.inspect)
		
		view1 = View.new('view1')
		assert_equal('#<View name=view1 w=0>', view1.inspect)
		
		view1 = View.new('view1')
		view1.draw_point([0, 0], 'A')
		assert_equal('#<View name=view1 w=1>', view1.inspect)
		
		view1.draw_point([0, 0], 'A')
		assert_equal('#<View name=view1 w=1>', view1.inspect)
		
		view1.draw_point([0, 1], 'B')
		assert_equal('#<View name=view1 w=1>', view1.inspect)
		
		view1.draw_point([1, 0], 'C')
		assert_equal('#<View name=view1 w=2>', view1.inspect)
	end
	
end
