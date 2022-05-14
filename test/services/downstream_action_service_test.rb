require 'test_helper'

class DownstreamsActionServiceTest < ActionDispatch::IntegrationTest

  def setup
    Hop.delete_all
    Session.delete_all
    @session = Session.create msisdn: '+256787737792',
      provider_key: 'testprovider', 
      provider_session_id: 0, 
      data:{'reference' => '111111'}
    @last_hop = Hop.new(session:@session, input:'111111')
    @instance = Mese::Config.instance_by_name 'testinstance'
  end

  #test 'downstream_action' do
  #  service = DownstreamActionService.new session: @session, 
  #    instance: @instance, 
  #    last_hop: @last_hop,
  #    action: 'validate_customer'
  #  stub_downstream_action
  #  service.perform!
  #  assert_equal 'John', service.new_session_data['customer_first_name']
  #  assert_equal 'Doe', service.new_session_data['customer_last_name']
  #end

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
      "page_ref" => nil,
      "session_data" => {'reference' => '111111'},
      "input" => '111111',
      "action" => 'validate_customer'
    }.to_json
  end

  def stub_downstream_action
    stub_request(:post, "#{@instance.base_url}/validate_customer/").with(**request_hash)
                                                       .to_return(status: 200, body: response_body, headers: {})
  end


  def response_body
    {
      'session_data' => {
        'customer_first_name': 'John',
        'customer_last_name': 'Doe'
      },
      'status' => 'success'
    }.to_json
  end
end
