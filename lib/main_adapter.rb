$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'adapters') 

module Main_Adapter
	extend self

	def adapter
		return @adapter if @adapter
		self.adapter = :xqueue # default adapter to xqueue
		@adapter
	end

	def adapter=(adapter_name)
		case adapter_name
		when Symbol, String
			require "adapters/#{adapter_name}"
			@adapter = Main_Adapter::Adapters.const_get("#{adapter_name.to_s.capitalize}")
		else
		  raise "Missing adapter #{adapter_name}"
		end
	end

	def looper
		adapter.looper()
	end
	def send_grade_response(score, comments, student_info, submission_info)
		adapter.send_grade_response(score,comments, student_info, submission_info)
	end
end