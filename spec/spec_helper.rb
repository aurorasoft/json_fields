ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")

if File.directory?(File.dirname(__FILE__) + "/matchers")
	Dir[File.dirname(__FILE__) + "/matchers/*.rb"].each {|file| require file }
end

require File.dirname(__FILE__) + '/test_models.rb'
require 'mocha'

Spec::Runner.configure do |config|
	# config.use_transactional_fixtures = true
	# config.use_instantiated_fixtures  = false
	# config.fixture_path = RAILS_ROOT + '/spec/fixtures'
	
	config.mock_with :mocha

	# You can declare fixtures for each behaviour like this:
	#   describe "...." do
	#     fixtures :table_a, :table_b
	#
	# Alternatively, if you prefer to declare them only once, you can
	# do so here, like so ...
	#
	#   config.global_fixtures = :table_a, :table_b
	#
	# If you declare global fixtures, be aware that they will be declared
	# for all of your examples, even those that don't use them.
end
