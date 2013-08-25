
describe "EdxController" do
	# Do not let fake http requests be sent.
	FakeWeb.allow_net_connect = false
	#FakeWeb.register_uri(:any, %r|http://username:password@queues-r-us.com/*|, :body => "Hello", :code => 200)
	let(:controller) {EdXController.new("django", "django_pass", "username", "password", "q1", "http://queues-r-us.com")}

	describe 'initialization' do
		it 'Should set the instance variables from the arguments' do
			controller.instance_eval{@queue_name}.should eq "q1"
			controller.instance_eval{@xqueue_url}.should eq "http://queues-r-us.com"
			controller.instance_eval{@django_auth}.should eq({'username' => "django", 'password' => "django_pass"})
			controller.instance_eval{@requests_auth}.should eq ['username','password']
			controller.instance_eval{@length_params}.should eq({'queue_name' => "q1"})
			controller.instance_eval{@pull_params}.should eq({'queue_name' => "q1"})
 		 end
	end

	describe 'Set queue_name' do
		before :each do
			controller.send(:set_queue_name, "newQ")
		end

		it 'Should allow the changing of the queues name' do
			controller.instance_eval{@queue_name}.should eq "newQ"
			controller.send(:set_queue_name, "newQ2")
			controller.instance_eval{@queue_name}.should eq "newQ2"
		end

		it 'Should change the length and pull parameters to match the new Queue name' do
			controller.instance_eval{@length_params}.should eq({'queue_name' => "newQ"})
			controller.instance_eval{@pull_params}.should eq({'queue_name' => "newQ"})

		end

	end

	describe 'Authentication' do
		after :each do
			FakeWeb.clean_registry
		end
		normal_response = {:body => "Hello", :status => ["200", "OK"], 'set-cookie' => "oatmeal_raisin;other-cookies"}

		it 'Should send a post request to the xqueue base url login address' do
			FakeWeb.register_uri(:post, "http://username:password@queues-r-us.com/xqueue/login/", normal_response)
			controller.authenticate
			FakeWeb.should have_requested(:post, 'http://username:password@queues-r-us.com/xqueue/login/')

		end

		it 'Should set the session_cookie variable equal to the cookie it receives from authentication' do
			FakeWeb.register_uri(:post, "http://username:password@queues-r-us.com/xqueue/login/", normal_response)
			controller.authenticate
			FakeWeb.should have_requested(:post, 'http://username:password@queues-r-us.com/xqueue/login/')
			controller.instance_eval{@session_cookie}.should eq "oatmeal_raisin"

		end

		xit 'Should raise an error if it can not parse the session cookie, or a bad response is sent'

	end

	describe 'Checking the Queue Length' do
		after :each do
			FakeWeb.clean_registry
		end
		normal_response = {:status => ["200", "OK"], :body => JSON.dump({'content'=> 3})}
		it "Should add the query string for the queue_ name to the http request" do
			FakeWeb.register_uri(:any, %r|http://username:password@queues-r-us.com/xqueue/get_queuelen/*|, normal_response )
			controller.get_queue_length
			qname_query = URI.encode_www_form({'queue_name' => "q1"})
			FakeWeb.should have_requested(:get,"http://username:password@queues-r-us.com/xqueue/get_queuelen/?#{qname_query}")
		end
		it "Should read the length of the queue from json serialized body of the response" do
			FakeWeb.register_uri(:get, %r|http://username:password@queues-r-us.com/xqueue/get_queuelen/*|, normal_response)
			controller.get_queue_length.should eq 3
		end

		it "Should raise an error when a non 200 response code is received" do
			bad_response = normal_response.clone
			bad_response[:status] = ["404", "error"]
			FakeWeb.register_uri(:get, %r|http://username:password@queues-r-us.com/xqueue/get_queuelen/*|, bad_response)
			lambda {controller.get_queue_length}.should raise_error
		end

	end

	describe 'Downloading Student Submissions' do
		student_data = JSON.generate({"submission_time" => 20250101010100, "anonymous_student_id" => "deadbeef1010" })
		student_files = JSON.generate({"part_1" => "http://www.remote-file-store.com"})
		xqueue_header = "Secret_callback_key"
		xbody = JSON.generate({"grader_payload" => "assign1-part-1", "student_info" => student_data})
		xpackage=JSON.generate({'xqueue_header'=> xqueue_header, "xqueue_body" => xbody, "xqueue_files" => student_files})
		download_body=JSON.generate('content'=>xpackage)

		good_response = {:status => ["200", "OK"], :body =>download_body}
		bad_response = {:status => ["400", "no submissions pending"], :body =>download_body}

		before :each do
			FakeWeb.register_uri(:get, %r|http://www.remote-file-store.com*|, :body => "puts 'Hello World'")
		end
		after :each do
			FakeWeb.clean_registry
		end

		it "Should download the file from the uri contained in the response from the edx server" do
			FakeWeb.register_uri(:get, %r|http://queues-r-us.com/xqueue/get_submission/*|, good_response)
			controller.get_submission
			FakeWeb.should have_requested(:get, "http://www.remote-file-store.com/")
		end

		it "Should append the queue_name as a query string to the http request" do
			FakeWeb.register_uri(:get, %r|http://queues-r-us.com/xqueue/get_submission/*|, good_response)
			qname_query = URI.encode_www_form({'queue_name' => "q1"})
			controller.get_submission
			FakeWeb.should have_requested(:get,"http://queues-r-us.com/xqueue/get_submission/?#{qname_query}")
		end

		it "get_submission should return a hash with keys of :file, :part_name and :student_info" do
			FakeWeb.register_uri(:get, %r|http://queues-r-us.com/xqueue/get_submission/*|, good_response)
			controller.get_submission.should be_kind_of(Hash)
			controller.get_submission[:file].should eq "puts 'Hello World'"
			controller.get_submission[:part_name].should eq "assign1-part-1"
			controller.get_submission[:student_info].should eq JSON.parse(student_data)
		end

		it "Should return nil if there is an error in the initial request to edX" do
			FakeWeb.register_uri(:get, %r|http://queues-r-us.com/xqueue/get_submission/*|, bad_response)
			controller.get_submission.should be_nil
		end

	end

	describe "send_grade_response" do

    after :each do
      FakeWeb.clean_registry
  	end

    it "Should not raise an error if a non ASCII string is included in the message" do
      FakeWeb.register_uri(:post, %r|http://username:password@queues-r-us.com/xqueue/put_result/|, :body => "hi")
      non_ascii_str = "cool \xC2"
      lambda{controller.send_grade_response("True", "100", non_ascii_str)}.should_not raise_error
    end

    it "Should send a response to edX" do
      FakeWeb.register_uri(:post, %r|http://username:password@queues-r-us.com/xqueue/put_result/|, :status => ["200", "OK"])
      controller.send_grade_response("True", "100", "Good work")
      FakeWeb.should have_requested(:post, "http://username:password@queues-r-us.com/xqueue/put_result/")
    end


	end

end
