#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'

class TestSize < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_to_s
		size1 = Size.new
		assert_equal(':', size1.to_s)
		
		size1 = Size.new(1)
		assert_equal('1:', size1.to_s)
		
		size1 = Size.new(nil, 1)
		assert_equal(':1', size1.to_s)
		
		size1 = Size.new(1, 2)
		assert_equal('1:2', size1.to_s)
	end
	
	def test_inspect
		size1 = Size.new
		assert_equal('<Size w=NIL h=NIL>', size1.inspect)
		
		size1 = Size.new(24)
		assert_equal('<Size w=24 h=NIL>', size1.inspect)
		
		size1 = Size.new(nil, 42)
		assert_equal('<Size w=NIL h=42>', size1.inspect)
		
		size1 = Size.new(24, 42)
		assert_equal('<Size w=24 h=42>', size1.inspect)
	end
	
end
