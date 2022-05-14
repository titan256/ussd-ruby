require 'test_helper'

class DownstreamsActionServiceTest < ActionDispatch::IntegrationTest

  def setup
    Hop.delete_all
    Session.delete_all
    @session = Session.create msisdn: '+256787737792',
      provider_key: 'testprovider', 
      provider_session_id: 0, 
      page_ref: '123',
      network_code: 64410,
      short_code: '*284*26#',
      data:{}
    @last_hop = Hop.new(session:@session, input:'111111')
    @instance = Mese::Config.instance_by_name 'testinstance'
  end

  test 'forward_to_downstream' do
    service = ForwardToDownstreamService.new session: @session, 
      instance: @instance, 
      last_hop: @last_hop
    stub_forward_to_downstream
    service.perform!
    assert_equal true, service.final
    assert_equal 'The session has ended', service.response_text
  end

  private

  def request_hash
    { body: request_body,
      headers: { 'Accept' => 'application/json', 
                  'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                  'Content-Type' => 'application/json',
                  'User-Agent' => 'Ruby' ,
                  'Api-Key' => @instance.api_key} }
  end

  def request_body
    {
      "session_id" => @session.id,
      "msisdn" => '+256787737792',
      "page_ref" => '123',
      "session_data" => {},
      "serviceCode" => '*284*26#',
      "networkCode" => 64410,
      "short_code" => '*284*26#',
      "network_code" => 64410,
      "input" => '111111',
    }.to_json
  end

  def stub_forward_to_downstream
    stub_request(:post, "#{@instance.base_url}").with(**request_hash)
                                                       .to_return(status: 200, body: response_body, headers: {})
  end


  def response_body
    {
      'session_data' => {},
      'final' => true,
      'response' => 'The session has ended',
      'status' => 'success'
    }.to_json
  end
end
