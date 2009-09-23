class JsonFieldsDefaultTestModel
	def json_field
		@json_field
	end
	def json_field=(new)
		@json_field=new
	end
end
class JsonFieldsSimpleTestModel < JsonFieldsDefaultTestModel
end
class JsonFieldsCustomTestModel < JsonFieldsDefaultTestModel
end
