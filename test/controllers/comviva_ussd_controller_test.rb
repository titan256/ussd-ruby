require 'test_helper'

class ComvivaUssdControllerTest < ActionDispatch::IntegrationTest

  def setup
    Hop.delete_all
    Session.delete_all
    @fenixdb = Mese::Config.instance_by_name 'admin_preview'
    @session_id = '123456789'
  end

  test 'forward template implementation success path' do
    get url(input: '3', new_request: true)
    session = Session.where(provider_session_id: @session_id).last
    assert_equal '260766251856', session.msisdn
    assert_equal 'zm_mtn', session.provider_key
    assert_equal 'teststub', session.short_code
    assert_equal 64502, session.network_code

    assert_equal session.id, Hop.last.session_id
    assert_equal '3', Hop.last.input

    assert_equal 'FC', @response.headers['Freeflow']
    assert_equal 'N', @response.headers['charge']
    assert_equal 0, @response.headers['amount']
    assert_equal @session_id, @response.headers['cpRefId']

    # response from the teststub menu
    assert_equal 'Pick 1 or 2', @response.body
  end

  private

  def url(input:, msisdn: '260766251856', provider_key: 'zm_mtn',
          short_code: 'teststub', session_id: @session_id, new_request: false)
    "/comviva_ussd/#{provider_key}/#{short_code}/notify?input=#{input}&sessionID=#{session_id}&msisdn=#{msisdn}&isnewrequest=#{new_request}"
  end

  def request_params(input:, msisdn: '260766251856', new_request: false, session_id: @session_id)
    new_request = new_request ? '1' : '0'
    { MSISDN: msisdn, subscriberInput: input, sessionId: session_id, isnewrequest: new_request }
  end

  def instance
    @instance ||= instance = Mese::Config.instance_by_name 'admin_preview'
  end

  def request_hash
    { body: /.*/,
      headers: { 'Accept' => 'application/json',
                 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                 'Api-Key' => @fenixdb.api_key,
                 'Content-Type' => 'application/json',
                 'User-Agent' => 'Ruby' } }
  end
end
