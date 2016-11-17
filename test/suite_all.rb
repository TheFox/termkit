#!/usr/bin/env ruby

if ENV['COVERAGE'] && ENV['COVERAGE'].to_i != 0
	require 'simplecov'
	require 'simplecov-phpunit'
	
	SimpleCov.formatter = SimpleCov::Formatter::PHPUnit
	SimpleCov.start do
		add_filter 'test'
	end
end

require_relative 'test_app'
require_relative 'test_app_controller'
require_relative 'test_cell_table_view'
require_relative 'test_clear_view_content'
require_relative 'test_controller'
require_relative 'test_key_event'
require_relative 'test_parent_class_not_initialized_exception'
require_relative 'test_point'
require_relative 'test_rect'
require_relative 'test_size'
require_relative 'test_table_view'
require_relative 'test_text_view'
require_relative 'test_ui_app'
require_relative 'test_unhandled_event_exception'
require_relative 'test_view'
require_relative 'test_view_content'
require_relative 'test_view_controller'
