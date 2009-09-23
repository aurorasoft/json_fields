######
# JSON-Stored Fields
# (c) 2008-2009 Aurora Software (http://www.aurorasoft.com.au)
#
# http://www.github.com/aurorasoft/json-fields-plugin
#
######

require 'json'

module JsonFields
	def self.included(base)
		base.extend(ClassMethods)
		base.class_eval do
			include InstanceMethods
			before_save :store_json_data
		end
	end
	
	module ClassMethods
		def set_json_field(field_name)
			define_method :json_backed_field_name do
				field_name.to_sym
			end
		end

		def has_json_field(*fields)
			if fields.is_a? Symbol then
				fields=[fields]
			end
			fields.each do |field|
				define_method("#{field.to_s}") do
					json_field_get(field)
				end
				define_method("#{field.to_s}=") do |value|
					json_field_set(field, value)
				end
			end
		end
	end

	module InstanceMethods
		# Default field name
		def json_backed_field_name
			:json_field
		end

		def json_field_get(field)
			load_json_data
			# NOTE: to_json forces symbols to string! So, convert here so as that
			#       we don't get caught out!
			@json_data[field.to_s]
		end

		def json_field_set(field, value)
			load_json_data
			# NOTE: to_json forces symbols to string! So, convert here so as that
			#       we don't get caught out!
			@json_data ||= {}
			@json_data[field.to_s]=value
		end

		def load_json_data
			if !respond_to?(:json_backed_field_name) then
				# We don't know which field to use
				raise 'Not a JSON-backed field'
			else
				if @json_data then
					# The data is already loaded - use the version in memory
				else
					# It's not loaded yet - do we have anything to load?
					if self.send(json_backed_field_name).blank? then
						# No data saved as yet - prepare an empty hash
						@json_data = {}
					else
						# We have data - parse it from JSON
						@json_data=JSON.parse(self.send(json_backed_field_name))
					end
				end
				return @json_data
			end
		end

		# before_save
		# Takes the current data in @json_data and stores it as test_results
		def store_json_data
			if !respond_to?(:json_backed_field_name) then
				# This model doesn't have the data field, so skip it
				return true
			else
				if !@json_data then
					# The JSON data hasn't even been loaded - so, leave the field as is
				else
					self.send("#{json_backed_field_name}=", @json_data.to_json)
				end
			end
		end
	end
end
