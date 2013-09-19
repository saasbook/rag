require_relative 'rag_logger'

class EdXController

  include RagLogger

  class EdXController::InvalidHTTPMethodError < StandardError ; end
  class EdXController::BadStatusCodeError < StandardError ; end

  require 'net/https'
  require 'json'
  require "addressable/uri"

  attr_accessor :base_uri, :queue_name

  HTTP_MODES = [:get, :post]

  def initialize(django_username, django_pass, user_auth, user_pass,queue_name,queue_uri)
    @queue_name = queue_name#move later
    @xqueue_url = queue_uri
  #  @queue_name ="BerkeleyX-cs169x"
    @django_auth = {'username' => django_username, 'password'=>django_pass}
    @requests_auth = [user_auth,user_pass]
    @length_params={'queue_name' => @queue_name}
    @pull_params=@length_params
  end

  def authenticate
   # begin
      #uri = URI.join(@xqueue_url,'xqueue/login')
      uri = URI.join(@xqueue_url, 'xqueue/','login/')
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.basic_auth(*@requests_auth)
      request.set_form_data(@django_auth)
      http.use_ssl = true

      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |https|
        https.request(request)
      end

    # response = http.request(request)
      #Should raise an error here since our authentication failed
      all_cookies=response['set-cookie']

     # all_cookies=""
      @session_cookie=all_cookies.split(/;/)[0]

  end

  def set_queue_name(queue_name)
   # puts "queue_name is #{queue_name}"
    @queue_name=queue_name
    @length_params={'queue_name' => @queue_name}
    @pull_params=@length_params
  end

  def get_queue_length(name="")
    begin
      length_uri= URI.join(@xqueue_url, 'xqueue/', 'get_queuelen/')
      length_uri.query = URI.encode_www_form(@length_params)
      length_http = Net::HTTP.new(length_uri.host, length_uri.port)
      length_http.use_ssl = true
      length_request= Net::HTTP::Get.new(length_uri.request_uri)
      length_request.basic_auth(*@requests_auth)
      length_request['cookie']=@session_cookie
      response = Net::HTTP.start(length_uri.host, length_uri.port, :use_ssl => length_uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |https|
        https.request(length_request)
      end

      if response.code.to_s =~ /[3-5]\d\d/
        logger.error "Bad queue length response: #{response['status']}"
        raise EdXController::BadStatusCodeError, "Bad queue length response: #{response['status']}"
      end
    end
      data=response.body
      parsed_data=JSON.parse(data)
      queue_length=parsed_data['content']
  end

  def get_submission()
    pull_uri= URI.join(@xqueue_url, 'xqueue/', 'get_submission/')
    pull_uri.query = URI.encode_www_form(@pull_params)
    pull_http = Net::HTTP.new(pull_uri.host, pull_uri.port)
    pull_http.use_ssl = true
    pull_request= Net::HTTP::Get.new(pull_uri.request_uri)
   # pull_request.basic_auth(*@requests_auth)
    pull_request['cookie']=@session_cookie

    pull_response=Net::HTTP.start(pull_uri.host, pull_uri.port,:use_ssl => pull_uri.scheme == 'https',:verify_mode => OpenSSL::SSL::VERIFY_NONE) do |https|
      https.request(pull_request)
    end
#      pull_response = pull_http.request(pull_request)

    if pull_response.code.to_s =~ /[3-5]\d\d/
        logger.error "Another queue already downloaded this file: #{pull_response['status']}"
       return nil# raise EdXController::BadStatusCodeError, "Concurrent grading error: #{pull_response['status']}"
    end
    xpackage=JSON.parse(pull_response.body)['content']
    xpackage=JSON.parse(xpackage)
    #puts xpackage
    @xheader = xpackage['xqueue_header'] # Xqueue callback, secret key
    @xbody   = JSON.parse(xpackage['xqueue_body'])   # Grader-specific serial data
    @xfiles  = xpackage['xqueue_files']  # JSON-serialized Dict {'filename': 'uploaded_file_url'} of student-uploaded files

    student_info = JSON.parse(@xbody["student_info"])

    #puts student_info
    logger.info "submission of: #{@xbody['grader_payload']}"
    logger.info "submission from: #{student_info["anonymous_student_id"]}"
    logger.info "submitted at #{student_info["submission_time"]}"
    xfiles_dict=JSON.parse(@xfiles)
    uploaded_file_url = xfiles_dict.values()[0] # Expecting just one file
    file_uri= Addressable::URI.parse(uploaded_file_url)
    file_http = Net::HTTP.new(file_uri.host, file_uri.port)
    file_http.use_ssl = true
    file_request= Net::HTTP::Get.new(file_uri.request_uri)

   file_response=Net::HTTP.start(file_uri.host, file_uri.port,:use_ssl => file_uri.scheme == 'https',:verify_mode => OpenSSL::SSL::VERIFY_NONE) do |https|
      https.request(file_request)
    end
   # file_response = file_http.request(file_request)

    file=file_response.body

    {:file => file, :part_name => @xbody['grader_payload'], :student_info=>student_info}#:submission_time => student_info["submission_time"]} #lot of redundancy now but no problem
  end
  #this is where we will send the response back to edX
  #should be called from EdXClient

  def send_grade_response(correct="True", score="100", msg="good work student")
   # Clobber all non utf-8 characters

   # This is a hack, if it is not UTF-8 or Ascii, clobber the non ascii/utf-8 chracter character
   if msg.encoding.name == "UTF-8"
     msg = msg.encode("ASCII-8BIT", :invalid => :replace, :undef =>:replace, :replace => "?")
   end
   msg = msg.encode("UTF-8", :invalid => :replace, :undef =>:replace, :replace => "?")

   #print new_msg
   #msg = new_msg.encode("UTF-8", :invalid => :replace, :undef =>:replace, :replace => "?")
   grader_reply= JSON.generate({:correct => correct, :score => score, :msg => msg})
    returnpackage = {'xqueue_header'=> @xheader,'xqueue_body'=> grader_reply}
    reply_uri =URI.join(@xqueue_url, 'xqueue/', 'put_result/')
    reply_http = Net::HTTP.new(reply_uri.host, reply_uri.port)
    reply_request = Net::HTTP::Post.new(reply_uri.request_uri)
    reply_request.basic_auth(*@requests_auth)
    reply_request.set_form_data(returnpackage)
    reply_http.use_ssl = true
    reply_request['cookie']=@session_cookie

    response =Net::HTTP.start(reply_uri.host, reply_uri.port, :use_ssl => reply_uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |https|
        https.request(reply_request)
    end

  #  puts "response is #{response}"
   # p response
   # Not sure what to do here, this means our response to edX is being rejected for some reason.
    if response.code.to_s !~ /2\d\d/
      logger.error "Bad post score response: #{response.code.to_s}"
      raise EdXController::BadStatusCodeError, "Bad post score response: #{response.code}"
    end
  end

end


