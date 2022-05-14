require 'test_helper'

class MoovUssdControllerTest < ActionDispatch::IntegrationTest

  def setup
    Hop.delete_all
    Session.delete_all
    @momoep = Mese::Config.instance_by_name 'momoep'
  end

  def assert_request input, page_ref
    get url, params: notify_request(input: input, session_id: @session_id)
    assert_equal @response.status, 200
    session = Session.where(provider_session_id: @session_id).last
    assert_not_nil session
    assert_equal page_ref, session.page_ref
    assert_equal Hop.last.session_id, session.id
    assert_equal Hop.last.input, input
  end

  def assert_session_variable name, value
    session = Session.where(provider_session_id: @session_id).last
    assert_equal session.data[name], value
  end

  def request_hash
    { body: /.*/,
      headers: { 'Accept' => 'application/json', 
                  'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                  'Content-Type' => 'application/json',
                  'User-Agent' => 'Ruby' ,
                  'Api-Key' => @momoep.api_key} }
  end

  def request_body
    {
      "session_id" => @session_id,
      "msisdn" => '+256787737792',
      "page_ref" => nil,
      "session_data" => {'reference' => '111111'},
      "input" => '111111',
      "action" => 'validate_customer'
    }.to_json
  end

  def response_body status
    {
      'session_data' => {
        'customer_first_name': 'John',
        'customer_last_name': 'Doe'
      },
      'status' => status
    }.to_json
  end

  def stub_validation status: 'success'
    stub_request(:post, "#{@momoep.base_url}/validate/").with(**request_hash)
                                                       .to_return(status: 200, body: response_body(status), headers: {})
  end

  def stub_payment status: 'success'
    stub_request(:post, "#{@momoep.base_url}/payment/").with(**request_hash)
                                                       .to_return(status: 200, body: response_body(status), headers: {})
  end
  test 'energy_happy_path' do
    @session_id = '12345'
    assert_request '', 'start_page'
    assert_request '1', 'pay_for_energy'
    stub_validation
    assert_request '11111', 'enter_energy_amount'
    assert_request '100', 'energy_confirmation'
    stub_payment
    assert_session_variable 'amount', '100'
    assert_request '1', 'payment_confirmation'
  end

  test 'subscription_happy_path' do
    @session_id = '12345'
    assert_request '', 'start_page'
    assert_request '2', 'pay_for_subscription'
    stub_validation
    assert_request '11111', 'enter_subscription_amount'
    assert_request '2', 'subscription_confirmation'
    stub_payment
    assert_session_variable 'amount', 5000
    assert_session_variable 'subscription_name', 'Platinium'
    assert_request '1', 'payment_confirmation'
  end

  test 'order_happy_path' do
    @session_id = '12345'
    assert_request '', 'start_page'
    assert_request '3', 'pay_for_order'
    stub_validation
    assert_request '11111', 'enter_order_amount'
    assert_request '100', 'order_confirmation'
    stub_payment
    assert_session_variable 'amount', '100'
    assert_request '1', 'payment_confirmation'
  end

  test 'energy_cancel' do
    @session_id = '12345'
    assert_request '', 'start_page'
    assert_request '1', 'pay_for_energy'
    stub_validation
    assert_request '11111', 'enter_energy_amount'
    assert_request '100', 'energy_confirmation'
    assert_request '2', 'payment_request_cancelled'
  end

  test 'energy_invalid_reference' do
    @session_id = '12345'
    assert_request '', 'start_page'
    assert_request '1', 'pay_for_energy'
    stub_validation status: 'invalid'
    assert_request 'invalid', 'customer_invalid'
  end

  def expected_response
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <response><screen_type>text</screen_type>
        <text>Veuillez entrer votre numéro de client</text>
        <session_op>continue</session_op> 
        <screen_id>pay_for_energy</screen_id>
      </response>
    XML
  end

  private

  def url(business_account: 'powercorner')
    "/ussd/bj_moov/#{business_account}/"
  end

  def notify_request(input: '', session_id: '142454563', sender_phone_number: '229')
    {user_input: input, session_id: session_id, msisdn: sender_phone_number, sc: '345', req_no: rand(100000)}
  end
end
