#!/usr/bin/env ruby

require 'minitest/autorun'
require 'termkit'

class TestUnhandledEventException < MiniTest::Test
	
	include TheFox::TermKit
	include TheFox::TermKit::Exception
	
	def test_unhandled_event_exception
		event1 = KeyEvent.new
		
		assert_raises(UnhandledEventException){ raise UnhandledEventException.new(event1), 'Foo Bar' }
	end
	
end
