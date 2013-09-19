require 'spec_helper'

describe "run_with_timeout" do
	def sleep_then_print(time, message)
		"sleep #{time}; echo #{message}"
	end

	it "should return the value of stdout if the command if it does not timeout" do
		msg, err, val = run_with_timeout(sleep_then_print(2, "hello world"), 4)
		msg.should == "hello world\n"
	end

	it "should return the exit status of the command if it does not timeout" do
		msg, err, val = run_with_timeout(sleep_then_print(2, "oops"), 4)
		val.should == 0
	end

	it "should raise a timeout error if the command times out" do
		lambda{run_with_timeout(sleep_then_print(10, "hello world"), 1)}.should raise_error
	end

end
