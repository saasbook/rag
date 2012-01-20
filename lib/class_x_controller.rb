class ClassXController
  class ClassXController::InvalidHTTPMethodError < StandardError ; end
  class ClassXController::BadStatusCodeError < StandardError ; end

  require 'net/https'
  require 'json'

  attr_accessor :base_uri

  HTTP_MODES = [:get, :post]

  def initialize(base_uri, api_key)
    @base_uri = base_uri
    @api_key = api_key # This can be found on the Course Settings page
  end

  # The response for this is currently undefined
  def get_user_info(user_id)
    params = {:user_id => user_id}
    response = send_request("assignment/api/user_info/", params, :get)
    response
  end

  # Returns length of queue
  # Beware of concurrency: just because you receive a non-zero return value 
  # from get_queue_length() doesn't mean you are guaranteed to receive a
  # submission from get_pending_submission()
  def get_queue_length(queue_name)
    params = {:queue => queue_name}
    response = send_request("assignment/api/queue_length/", params, :get)
    response['queue_length']
  end

  # Returns either nil or 
  # {
  #   "api_state": ...
  #   "user_info": ...
  #   "submission_metadata": {“id”: X, ...}
  #   "solutions": ...
  #   "submission_encoding": ... (will be set to ‘base64’)
  #   "submission": (actual user submission in Base64 format) }
  # }
  def get_pending_submission(queue_name)
    params = {:queue => queue_name}
    response = send_request("assignment/api/pending_submission/", params, :get)
    response['submission']
  end

  # This is untested
  def get_submission(submission_id)
    params = {:submission_id => submission_id}
    response = send_request("assignment/api/submission/", params, :get)
    response['submission']
  end

  # Raises BadStatusCode if response status isn't 2xx (success)
  def post_score(api_state, score, feedback="", options={})
    params = {:api_state => api_state, :score => score, :feedback => feedback, :options => options.to_json}
    response = send_request("assignment/api/score/", params, :post)
    if response['status'] !~ /2\d\d/
      raise ClassXController::BadStatusCode, "Bad post score response: #{response['status']}"
    end
  end

  private

  # Sends an HTTPS GET request to the application path with the provided parameters.
  # Returns a Hash representing the JSON-encoded response.
  def send_request(path, params={}, mode=:get)
    unless HTTP_MODES.include? mode
      raise ClassXController::InvalidHTTPMethodError, "Invalid mode: #{mode}"
    end
    uri = URI.join(@base_uri, path)
    uri.query = URI.encode_www_form(params) if mode == :get

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(params) if mode == :post
    request['X-api-key'] = @api_key

    response = http.request(request)
    JSON.parse(response.body)
  end
end
