require File.dirname(__FILE__) + '/../spec_helper'

describe 'JsonFields' do
	it "should add class methods to ActiveRecord::Base" do
		ActiveRecord::Base.should respond_to(:has_json_field)
		ActiveRecord::Base.should respond_to(:set_json_field)
	end

	it "should add relevant hooks to before_save" do
		JsonFieldsDefaultTestModel.expects(:before_save).with(:store_json_data)
		JsonFieldsDefaultTestModel.class_eval do
			include JsonFields
			has_json_field :field_1, :field_2, :field_3
		end
	end

	it "should accept single field to add" do
		JsonFieldsSimpleTestModel.expects(:before_save).with(:store_json_data)
		JsonFieldsSimpleTestModel.class_eval do
			include JsonFields
			has_json_field :field_1
		end
		@i=JsonFieldsSimpleTestModel.new
		@i.should respond_to(:field_1)
	end

	describe "instance with default field name" do
		before do
			JsonFieldsDefaultTestModel.expects(:before_save).with(:store_json_data)
			JsonFieldsDefaultTestModel.class_eval do
				include JsonFields
				has_json_field :field_1, :field_2, :field_3
			end
			@i=JsonFieldsDefaultTestModel.new
		end

		it "should respond to added methods" do
			@i.should respond_to(:json_field_get)
			@i.should respond_to(:json_field_set)
			%w( field_1 field_2 field_3 ).each do |field|
				@i.should respond_to(field.to_sym)
				@i.should respond_to("#{field}=".to_sym)
			end
		end

		it "should get and set fields manually by strings" do
			@i.json_field_set('foo', 100)
			@i.json_field_set('bar', 200)
			@i.instance_variable_get(:@json_data).should == { 'foo' => 100, 'bar' => 200 }
			@i.json_field_get('foo').should == 100
			@i.json_field_get('bar').should == 200
		end

		it "should manually get missing fields OK" do
			@i.json_field_get('missingfield').should be_nil
			@i.json_field_get(:missingfield).should be_nil
		end

		it "should get and set fields manually by symbols" do
			@i.json_field_set(:foo, 100)
			@i.json_field_set(:bar, 200)
			# Internally, we store everything as strings because JSON can't handle symbols correctly
			@i.instance_variable_get(:@json_data).should == { 'foo' => 100, 'bar' => 200 }
			@i.json_field_get(:foo).should == 100
			@i.json_field_get(:bar).should == 200
		end

		it "should get and set fields by the added methods" do
			@i.field_1=100
			@i.field_2=200
			@i.json_field_set(:field_3, 300)
			@i.instance_variable_get(:@json_data).should == { 'field_1' => 100, 'field_2' => 200, 'field_3' => 300 }
			@i.field_1.should == 100
			@i.field_2.should == 200
			@i.field_3.should == 300
			@i.json_field_get(:field_1).should == 100
			@i.json_field_get(:field_2).should == 200
			@i.json_field_get(:field_3).should == 300
		end

		it "should set field data as JSON before_save" do
			data={ :foo => 100, :bar => 200 }
			data.each do |key, value|
				@i.json_field_set(key, value)
			end
			@i.store_json_data
			@i.json_field.should == '{"foo":100,"bar":200}'
		end

		it "should load the field data from JSON on first read" do
			@i.stubs(:json_field).returns("{\"a\":50,\"b\":150}")
			@i.json_field_get(:a).should == 50
			@i.json_field_get(:b).should == 150
		end
	end

	describe "instance with custom field name" do
		before do
			JsonFieldsCustomTestModel.expects(:before_save).with(:store_json_data)
			JsonFieldsCustomTestModel.class_eval do
				include JsonFields
				has_json_field :field_1, :field_2, :field_3
				set_json_field :custom_json_field
			end
			@i=JsonFieldsCustomTestModel.new
		end

		it "should set field data as JSON before_save" do
			@i.stubs(:custom_json_field).with(nil)
			@i.expects(:custom_json_field=).with('{"foo":100,"bar":200}')
			data={ :foo => 100, :bar => 200 }
			data.each do |key, value|
				@i.json_field_set(key, value)
			end
			@i.store_json_data
		end

		it "should load the field data from JSON on first read" do
			@i.stubs(:custom_json_field).returns("{\"a\":50,\"b\":150}")
			@i.json_field_get(:a).should == 50
			@i.json_field_get(:b).should == 150
		end
	end
end
