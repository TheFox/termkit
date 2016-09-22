#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'

class TestClearViewContent < MiniTest::Test
	
	include TheFox::TermKit
	
	def test_clear_view_content
		content1 = ClearViewContent.new
		
		assert_instance_of(ClearViewContent, content1)
		
		assert_kind_of(ClearViewContent, content1)
		assert_kind_of(ViewContent, content1)
	end
	
	def test_to_s
		content1 = ClearViewContent.new
		assert_equal(' ', content1.to_s)
		
		content1 = ClearViewContent.new('#')
		assert_equal('#', content1.to_s)
	end
	
end
