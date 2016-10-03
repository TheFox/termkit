#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'

class TestViewContent < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_view_content
		content1 = ViewContent.new('A')
		assert_equal(true, content1.needs_rendering)
	end
	
	def test_to_s
		char = 'A'
		
		content1 = ViewContent.new(char)
		assert_equal('A', content1.to_s)
		assert_equal('A', char)
		
		char = 'B'
		assert_equal('A', content1.to_s)
	end
	
	def test_inspect
		content1 = ViewContent.new('A')
		assert_equal(%{<ViewContent c='A' r?=Y v=>}, content1.inspect)
		
		view1 = View.new('view1')
		content1 = ViewContent.new('A', view1)
		assert_equal(%{<ViewContent c='A' r?=Y v=view1>}, content1.inspect)
	end
	
end
