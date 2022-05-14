require 'test_helper'

# tests forwarding and routing for the base ussd controller
class UssdControllerTest < ActionDispatch::IntegrationTest

  def setup
    Hop.delete_all
    Session.delete_all
    @fenixdb = Mese::Config.instance_by_name 'fenixdb'
    @uganda = Mese::Config.instance_by_name 'uganda'
    @session_id = '123456789'
  end

  test 'forward template implementation success path' do
    stub_forward_to_downstream_accepted @fenixdb
    post url, params: notify_request(session_id: @session_id)
    assert_equal 200, @response.status
    assert_equal 'END Hello this is fenixdb', @response.body
  end

  test 'forward template moves to second if first rejects' do
    stub_forward_to_downstream_rejected @fenixdb
    stub_forward_to_downstream_accepted @uganda
    post url, params: notify_request(session_id: @session_id)
    assert_equal 200, @response.status
    assert_equal 'END Hello this is uganda', @response.body
  end

  test 'forward template renders error if all downstreams reject' do
    stub_forward_to_downstream_rejected @fenixdb
    stub_forward_to_downstream_rejected @uganda
    post url, params: notify_request(session_id: @session_id)
    assert_equal 200, @response.status
    assert_equal 'END An error has occured', @response.body
  end
  private

  def url(provider_key: 'ug_africastalking', business_account: 'fenixintl')
    "/africastalking_ussd/#{provider_key}/#{business_account}/fakeapikey/"
  end

  def notify_request(input: '', session_id: '142454563', sender_phone_number: '256782529687')
    {
      text: input,
      sessionId: session_id,
      phoneNumber: sender_phone_number,
      networkCode: '64410',
      serviceCode: '*284*6#'
    }
  end

  def request_hash instance
    { body: /.*/,
      headers: { 'Accept' => 'application/json', 
                  'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                  'Content-Type' => 'application/json',
                  'User-Agent' => 'Ruby' ,
                  'Api-Key' => instance.api_key} }
  end

  def request_body
    {
      "session_id" => /.*/,
      "msisdn" => '256782529687',
      "page_ref" => nil,
      "session_data" => {},
      "serviceCode" => '*284*6#',
      "networkCode" => 64410,
      "short_code" => '*284*6#',
      "network_code" => 64410,
      "input" => '',
    }.to_json
  end

  def stub_forward_to_downstream_accepted instance
    stub_request(:post, "#{instance.base_url}").with(**request_hash(instance))
      .to_return(status: 200, body: response_body(instance.name), headers: {})
  end

  def stub_forward_to_downstream_rejected instance
    stub_request(:post, "#{instance.base_url}").with(**request_hash(instance))
      .to_return(status: 404, body: response_body(instance.name), headers: {})
  end

  def response_body name
    {
      'session_data' => {},
      'final' => true,
      'response' => "Hello this is #{name}",
      'status' => 'success'
    }.to_json
  end
end
