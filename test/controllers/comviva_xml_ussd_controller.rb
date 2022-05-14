require 'test_helper'

class ComvivaXmlUssdControllerTest < ActionDispatch::IntegrationTest

  def setup
    Hop.delete_all
    Session.delete_all
    @fenixdb = Mese::Config.instance_by_name 'fenixdb'
    @session_id = '123456789'
  end

  test 'forward template implementation success path' do
    post url, params: request_xml(input: '3'), as: :raw_xml
    session = Session.where(provider_session_id: @session_id).last
    assert_equal '260766251856', session.msisdn
    assert_equal 'ug_mtn', session.provider_key
    assert_equal 'teststub', session.short_code
    assert_equal 64410, session.network_code

    assert_equal session.id, Hop.last.session_id
    assert_equal '3', Hop.last.input
  end

  private

  def url
    '/comviva_ussd_xml/ug_mtn/teststub/notify'
  end

  def request_xml(input: '', msisdn: '260766251856', provider_key: 'zm_mtn',
          short_code: 'teststub', session_id: @session_id, new_request: false)
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <request type="pull">
       <subscriberInput>#{input}</subscriberInput>
       <sessionId>#{session_id}</sessionId>
       <msisdn>#{msisdn}</msisdn>
       <dateFormat>20220514134840959</dateFormat>
       <newRequest>#{new_request}</newRequest>
       <transactionId>01102716525253204945</transactionId>
       <parameters>
       </parameters>
       <freeflow>
        <mode>FE</mode>
       </freeflow>
      </request>
    XML
  end

end
