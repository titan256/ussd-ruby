require 'test_helper'

class AfricastalkingUssdControllerTest < ActionDispatch::IntegrationTest

  def setup
    Hop.delete_all
    Session.delete_all
    @momoep = Mese::Config.instance_by_name 'momoep'
  end

  def assert_request input, page_ref
    post url, params: notify_request(input: input, session_id: @session_id)
    assert_equal @response.status, 200
    session = Session.where(provider_session_id: @session_id).last
    assert_not_nil session
    assert_equal page_ref, session.page_ref
    assert_equal Hop.last.session_id, session.id
    assert_equal Hop.last.input, input

    assert_equal session.short_code, '*284*26#'
    assert_equal session.network_code, 64110
  end

  def assert_session_variable name, value
    session = Session.where(provider_session_id: @session_id).last
    assert_equal session.data[name], value
  end

  test 'energy_happy_path' do
    @session_id = '12345'
    assert_request '', 'start_page'
    assert_request '1', 'pay_for_energy'
    stub_validation
    assert_request '11111', 'enter_energy_amount'
    assert_request '100', 'energy_confirmation'
    assert_session_variable 'payment_amount', '100'
    stub_payment
    assert_request '1', 'payment_confirmation'
  end

  test 'invalid_account' do
    @session_id = '12345'
    assert_request '', 'start_page'
    assert_request '1', 'pay_for_energy'
    stub_validation status: 'invalid'
    assert_request '22222', 'customer_invalid'
  end

  test 'ice_happy_path' do
    @session_id = '12345'
    assert_request '', 'start_page'
    assert_request '5', 'pay_for_ice'
    stub_validation
    assert_request '11111', 'enter_ice_method'
    assert_request '1', 'ice_amount_sacks'
    assert_session_variable 'payment_method', 'ice'
    assert_request '3', 'ice_confirmation'
    assert_session_variable 'payment_quantity', '3'
    assert_session_variable 'payment_method_conversion', 17700
    stub_payment
    assert_request '1', 'payment_confirmation'
    assert_session_variable 'amount', '53100'
  end

  test 'fish_happy_path' do
    @session_id = '12345'
    assert_request '', 'start_page'
    assert_request '3', 'pay_for_fish_drying'
    stub_validation
    assert_request '11111', 'enter_fish_method'
    assert_request '1', 'fish_drying_amount_basins'
    assert_session_variable 'payment_method', 'fish'
    assert_request '3', 'fish_drying_confirmation'
    assert_session_variable 'payment_quantity', '3'
    assert_session_variable 'payment_method_conversion', 2000
    stub_payment
    assert_request '1', 'payment_confirmation'
    assert_session_variable 'amount', '6000'
  end

  test 'order_happy_path' do
    @session_id = '12345'
    assert_request '', 'start_page'
    assert_request '2', 'pay_for_order'
    stub_validation
    assert_request '11111', 'enter_order_amount'
    assert_request '100', 'order_confirmation'
    assert_session_variable 'payment_amount', '100'
    stub_payment
    assert_request '1', 'payment_confirmation'
  end

  test 'water_happy_path' do
    @session_id = '12345'
    assert_request '', 'start_page'
    assert_request '4', 'pay_for_water'
    stub_validation
    assert_request '11111', 'enter_water_method'
    assert_request '1', 'refill_amount'
    assert_request '2', 'refill_confirmation'
    assert_session_variable 'payment_method', 'water'
    assert_session_variable 'payment_quantity', '2'
    stub_payment
    assert_request '1', 'payment_confirmation'
    assert_session_variable 'payment_amount', '12000'
  end

  test 'invalid_amount' do
    @session_id = '12345'
    assert_request '', 'start_page'
    assert_request '5', 'pay_for_ice'
    stub_validation
    assert_request '11111', 'enter_ice_method'
    assert_request '1', 'ice_amount_sacks'
    assert_session_variable 'payment_method', 'ice'
    assert_request '1.2', 'amount_invalid'
  end

  private

  def url(provider_key: 'ug_africastalking', business_account: 'power_corner')
    "/africastalking_ussd/#{provider_key}/#{business_account}/#{api_key}/"
  end

  def notify_request(input: '', session_id: '142454563', sender_phone_number: '256782529687')
    {
      text: input,
      sessionId: session_id,
      phoneNumber: sender_phone_number,
      networkCode: '64110',
      serviceCode: '*284*26#'
    }
  end

  def api_key
    'asdfsdfsdfa' 
  end

  def request_hash
    { body: /.*/,
      headers: { 'Accept' => 'application/json', 
                  'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                  'Content-Type' => 'application/json',
                  'User-Agent' => 'Ruby' ,
                  'Api-Key' => instance.api_key} }
  end

  def request_body session
    {
      "session_id" => session.id,
      "msisdn" => '256782529687',
      "page_ref" => session.page_ref,
      "session_data" => {'reference' => '111111'},
      "input" => '1',
      "action" => 'validate'
    }.to_json
  end

  def instance
    @instance ||= instance = Mese::Config.instance_by_name 'momoep'
  end

  def response_body status
    {
      'status' => status,
      'session_data' => {
        'customer_name' => 'John Doe',
      },
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

  def stub_downstream_action session
    stub_request(:post, "#{instance.base_url}/validate/").with(**request_hash(session))
      .to_return(status: 200, body: response_body, headers: {})
  end
end
