#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'

class TestPoint < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_point
		point1 = Point.new
		assert_same(nil, point1.x)
		assert_same(nil, point1.y)
		
		point1 = Point.new(21, 42)
		assert_same(21, point1.x)
		assert_same(42, point1.y)
		
		point1 = Point.new([21, 42])
		assert_same(21, point1.x)
		assert_same(42, point1.y)
		
		point1 = Point.new({'x' => 21, 'y' => 42})
		assert_same(21, point1.x)
		assert_same(42, point1.y)
		
		point1 = Point.new({:x => 21, :y => 42})
		assert_same(21, point1.x)
		assert_same(42, point1.y)
	end
	
	def test_plus
		point1 = Point.new
		point2 = Point.new
		point3 = point1 + point2
		assert_nil(point3.x)
		assert_nil(point3.y)
		
		point1 = Point.new(1, 2)
		point2 = Point.new
		point3 = point1 + point2
		assert_equal(1, point3.x)
		assert_equal(2, point3.y)
		
		point1 = Point.new
		point2 = Point.new(2, 1)
		point3 = point1 + point2
		assert_equal(2, point3.x)
		assert_equal(1, point3.y)
		
		point1 = Point.new(1, 2)
		point2 = Point.new(3, 4)
		point3 = point1 + point2
		assert_equal(4, point3.x)
		assert_equal(6, point3.y)
	end
	
	def test_minus
		point1 = Point.new
		point2 = Point.new
		point3 = point1 - point2
		assert_nil(point3.x)
		assert_nil(point3.y)
		
		point1 = Point.new(1, 2)
		point2 = Point.new
		point3 = point1 - point2
		assert_equal(1, point3.x)
		assert_equal(2, point3.y)
		
		point1 = Point.new
		point2 = Point.new(2, 1)
		point3 = point1 - point2
		assert_equal(-2, point3.x)
		assert_equal(-1, point3.y)
		
		point1 = Point.new(1, 2)
		point2 = Point.new(3, 4)
		point3 = point1 - point2
		assert_equal(-2, point3.x)
		assert_equal(-2, point3.y)
		
		point1 = Point.new(10, 5)
		point2 = Point.new(3, 2)
		point3 = point1 - point2
		assert_equal(7, point3.x)
		assert_equal(3, point3.y)
	end
	
	def test_to_s
		point1 = Point.new
		assert_equal(':', point1.to_s)
		
		point1 = Point.new(1)
		assert_equal('1:', point1.to_s)
		
		point1 = Point.new(nil, 1)
		assert_equal(':1', point1.to_s)
		
		point1 = Point.new(1, 2)
		assert_equal('1:2', point1.to_s)
	end
	
	def test_to_a
		x, y = Point.new.to_a
		assert_nil(x)
		assert_nil(y)
		
		x, y = Point.new(1).to_a
		assert_equal(1, x)
		assert_nil(y)
		
		x, y = Point.new(nil, 2).to_a
		assert_nil(x)
		assert_equal(2, y)
		
		x, y = Point.new(1, 2).to_a
		assert_equal(1, x)
		assert_equal(2, y)
	end
	
	def test_inspect
		point1 = Point.new
		assert_equal('#<Point x=NIL y=NIL>', point1.inspect)
		
		point1 = Point.new(1)
		assert_equal('#<Point x=1 y=NIL>', point1.inspect)
		
		point1 = Point.new(nil, 1)
		assert_equal('#<Point x=NIL y=1>', point1.inspect)
		
		point1 = Point.new(1, 2)
		assert_equal('#<Point x=1 y=2>', point1.inspect)
	end
	
	def test_from_s
		point1 = Point.from_s(':')
		assert_nil(point1.x)
		assert_nil(point1.y)
		
		point1 = Point.from_s('1:')
		assert_equal(1, point1.x)
		assert_nil(point1.y)
		
		point1 = Point.from_s(':2')
		assert_nil(point1.x)
		assert_equal(2, point1.y)
		
		point1 = Point.from_s('1:2')
		assert_equal(1, point1.x)
		assert_equal(2, point1.y)
	end
	
end
