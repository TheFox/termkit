#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'

class TestParentClassNotInitializedException < MiniTest::Test
	
	include TheFox::TermKit::Exception
	
	def test_parent_class_not_initialized_exception
		assert_raises(ParentClassNotInitializedException){ raise ParentClassNotInitializedException, 'Foo Bar' }
	end
	
end
