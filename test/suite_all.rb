#!/usr/bin/env ruby

# require 'minitest/reporters'
# Minitest::Reporters.use!

if ENV['COVERAGE'] && ENV['COVERAGE'].to_i != 0
	require 'simplecov'
	require 'simplecov-phpunit'
	
	SimpleCov.formatter = SimpleCov::Formatter::PHPUnit
	SimpleCov.start do
		add_filter 'test'
	end
end

require_relative 'test_app'
# require_relative 'test_app_curses'
require_relative 'test_app_ui'
require_relative 'test_content_view'
require_relative 'test_controller'
require_relative 'test_controller_app'
require_relative 'test_controller_view'
require_relative 'test_event_key'
require_relative 'test_exception_event_unhandled'
require_relative 'test_exception_initialized_not_class_parent'
require_relative 'test_point'
require_relative 'test_rect'
require_relative 'test_size'
require_relative 'test_view'
require_relative 'test_view_table'
require_relative 'test_view_table_cell'
require_relative 'test_view_text'
