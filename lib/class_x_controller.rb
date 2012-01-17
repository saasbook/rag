class ClassXController
  require 'net/https'
  require 'json'

  attr_accessor :base_uri

  def initialize(base_uri, api_key)
    @base_uri = base_uri
    @api_key = api_key
  end

  def start
  end

  def get_queue_length(queue_name)
    params = {:queue => queue_name}
    response = send_get_request "assignment/api/queue_length/", params
    response['queue_length']
  end

  def get_submission(queue_name)
    params = {:queue => queue_name}
    response = send_get_request "assignment/api/pending_submission/", params
    response['submission']
  end

  def post_score(api_state, score, feedback="", options={})
    # Returns whether response status was 2xx (success)
    params = {:api_state => api_state, :score => score, :feedback => feedback, :options => options.to_json}
    response = send_post_request "assignment/api/score/", params
    response['status'] =~ /2\d\d/
  end

  private

  def send_get_request(path, params={})
    # Sends an HTTPS GET request to the application path with the provided parameters.
    # Returns a Hash representing the JSON-encoded response.
    uri = URI.join(@base_uri, path)
    uri.query = URI.encode_www_form(params)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Get.new(uri.request_uri)
    request['X-api-key'] = @api_key

    response = http.request(request)
    JSON.parse(response.body)
  end

  def send_post_request(path, params={})
    # Sends an HTTPS GET request to the application path with the provided parameters.
    # Returns a Hash representing the JSON-encoded response.
    uri = URI.join(@base_uri, path)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(params)
    request['X-api-key'] = @api_key

    response = http.request(request)
    JSON.parse(response.body)
  end
end
