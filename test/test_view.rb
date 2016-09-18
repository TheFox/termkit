#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'
require 'pp'


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
	
	def test_is_visible
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
	
	def test_draw_point_simple
		puts
		puts '-- Simple ----------'
		
		view1 = View.new('view1')
		view1.is_visible = true
		
		assert_equal(true, view1.draw_point([0, 0], 'A'))
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
		
		assert_equal(true, view1.draw_point([0, 0], 'A'))
		assert_equal(true, view2.draw_point([0, 0], 'B'))
		
		assert_equal('A', view1.grid[0][0].char)
		assert_nil(view1.grid[0][1])
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
	end
	
	def test_draw_point_subviews_chain1
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
		
		# assert_equal(true, view1.draw_point([0, 0], 'A'))
		# assert_equal(true, view1.draw_point([1, 0], 'A'))
		# assert_equal(true, view2.draw_point([0, 0], 'B'))
		# assert_equal(true, view2.draw_point([1, 0], 'B'))
		assert_equal(true, view3.draw_point([0, 0], 'C'))
		
		# pp view1.pp_grid_cache
		# pp view2.pp_grid_cache
		# pp view3.pp_grid_cache
		
		assert_equal('C', view3.grid_cache[0][0].char)
		assert_equal('C', view2.grid_cache[0][1].char)
		assert_equal('C', view1.grid_cache[0][2].char)
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
		
		assert_equal(true, view1.draw_point([0, 0], 'A'))
		assert_equal(true, view1.draw_point([1, 0], 'A'))
		assert_equal(true, view2.draw_point([0, 0], 'B'))
		assert_equal(true, view2.draw_point([1, 0], 'B'))
		assert_equal(true, view3.draw_point([0, 0], 'C'))
		
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
		
		assert_equal(true, view3.draw_point([0, 0], 'C'))
		
		# pp view1.pp_grid_cache
		# pp view2.pp_grid_cache
		# pp view3.pp_grid_cache
		
		assert_equal('C', view3.grid_cache[0][0].char)
		assert_equal('C', view2.grid_cache[0][1].char)
		assert_equal('C', view1.grid_cache[0][2].char)
		
		assert_equal(true, view2.draw_point([1, 0], 'B'))
		assert_equal(true, view2.draw_point([0, 0], 'B'))
		
		# pp view1.pp_grid_cache
		# pp view2.pp_grid_cache
		# pp view3.pp_grid_cache
		
		assert_equal('C', view3.grid_cache[0][0].char)
		assert_equal('C', view2.grid_cache[0][1].char)
		assert_equal('C', view1.grid_cache[0][2].char)
		
		assert_equal('B', view2.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		
		assert_equal(true, view1.draw_point([1, 0], 'A'))
		assert_equal(true, view1.draw_point([0, 0], 'A'))
		
		# pp view1.pp_grid_cache
		# pp view2.pp_grid_cache
		# pp view3.pp_grid_cache
	end
	
	def test_draw_point_visible_false
		puts
		puts '-- Visible false ---'
		
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.position = Point.new(1, 0)
		view2.is_visible = false
		view1.add_subview(view2)
		
		assert_equal(true, view1.draw_point([0, 0], 'A'))
		assert_equal(true, view2.draw_point([0, 0], 'B'))
		
		assert_equal('A', view1.grid[0][0].char)
		assert_nil(view1.grid[0][1])
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_nil(view1.grid_cache[0][1])
	end
	
	def test_draw_point_visible_true
		puts
		puts '-- Visible true ----'
		
		view1 = View.new('view1')
		view1.is_visible = true
		
		view2 = View.new('view2')
		view2.position = Point.new(1, 0)
		view2.is_visible = false
		view1.add_subview(view2)
		
		assert_equal(true, view1.draw_point([0, 0], 'A'))
		assert_equal(true, view2.draw_point([0, 0], 'B'))
		
		assert_equal('A', view1.grid[0][0].char)
		assert_nil(view1.grid[0][1])
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_nil(view1.grid_cache[0][1])
		
		assert_equal('B', view2.grid[0][0].char)
		assert_equal('B', view2.grid_cache[0][0].char)
		
		view2.is_visible = true
		
		# pp view1.grid_cache[0]
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		
		view2.is_visible = false
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_nil(view1.grid_cache[0][1])
	end
	
	def test_draw_point_zindex_base
		puts
		puts '-- Zindex ----------'
		
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
		
		assert_equal(true, view1.draw_point([0, 0], 'A'))
		assert_equal(true, view2.draw_point([0, 0], 'B'))
		assert_equal(true, view2.draw_point([1, 0], 'C'))
		assert_equal(true, view3.draw_point([0, 0], 'D'))
		
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
		
		assert_equal(true, view1.draw_point([0, 0], 'A'))
		assert_equal(true, view1.draw_point([1, 0], 'A'))
		assert_equal(true, view1.draw_point([2, 0], 'A'))
		assert_equal(true, view2.draw_point([0, 0], 'B'))
		assert_equal(true, view2.draw_point([1, 0], 'B'))
		assert_equal(true, view3.draw_point([0, 0], 'C'))
		
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
		
		assert_equal(true, view1.draw_point([0, 0], 'A'))
		assert_equal(true, view1.draw_point([1, 0], 'A'))
		assert_equal(true, view1.draw_point([2, 0], 'A'))
		# assert_equal(true, view1.draw_point([3, 0], 'A'))
		assert_equal(true, view2.draw_point([0, 0], 'B'))
		assert_equal(true, view2.draw_point([1, 0], 'B'))
		assert_equal(true, view2.draw_point([2, 0], 'B'))
		# assert_equal(true, view2.draw_point([3, 0], 'B'))
		assert_equal(true, view3.draw_point([0, 0], 'C'))
		assert_equal(true, view4.draw_point([0, 0], 'D'))
		assert_equal(true, view4.draw_point([1, 0], 'D'))
		
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
		
		puts '-' * 20
		puts '-' * 20
		puts '-' * 20
		
		view4.zindex = 0
		
		puts '-' * 20
		puts '-' * 20
		puts '-' * 20
		
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
		
		assert_equal(true, view1.draw_point([0, 0], 'A'))
		assert_equal(true, view1.draw_point([1, 0], 'B'))
		assert_equal(true, view1.draw_point([2, 0], 'C'))
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		assert_equal('C', view1.grid_cache[0][2].char)
		
		view2 = View.new('view2')
		view2.position = Point.new(2, 0)
		view2.is_visible = true
		
		assert_equal(true, view2.draw_point([0, 0], 'D'))
		
		view1.add_subview(view2)
		
		assert_equal('A', view1.grid_cache[0][0].char)
		assert_equal('B', view1.grid_cache[0][1].char)
		assert_equal('D', view1.grid_cache[0][2].char)
	end
	
	def test_draw_point_remove_subview
		view1 = View.new('view1')
		view1.is_visible = true
		
		assert_equal(true, view1.draw_point([0, 0], 'A'))
		assert_equal(true, view1.draw_point([1, 0], 'B'))
		assert_equal(true, view1.draw_point([2, 0], 'C'))
		
		view2 = View.new('view2')
		view2.position = Point.new(2, 0)
		view2.is_visible = true
		
		assert_equal(true, view2.draw_point([0, 0], 'D'))
		
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
	
	def test_set_grid_cache
		content1 = ViewContent.new('A')
		content2 = ViewContent.new('B')
		
		view1 = View.new('view1')
		
		assert_equal(true, view1.set_grid_cache(Point.new(0, 0), content1))
		assert_equal(false, view1.set_grid_cache(Point.new(0, 0), content1))
		assert_equal(true, view1.set_grid_cache(Point.new(0, 0), content2))
	end
	
	def test_render
		view1 = View.new('view1')
		
		view1.render
	end
	
end
