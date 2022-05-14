class MoovUssdController < UssdController
  def provider_key
    'bj_moov'
  end

  def parse_ussd_params
    Rails.logger.info "MoovUssdController #notify: #{params.inspect}"
    ussd_params = {}
    ussd_params[:msisdn] = params['msisdn']
    ussd_params[:provider_session_id] = params['session_id']
    ussd_params[:raw_input] = params['user_input']
    ussd_params[:input] = [params['user_input']]
    ussd_params[:short_code] = params['sc']
    ussd_params[:network_code] = provider.details['network_code']

    ussd_params
  end

  private

  def render_response(final: false, msg:)
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <response><screen_type>menu</screen_type>
        <text>#{msg}</text>
        <session_op>#{final ? 'end' : 'continue'}</session_op> 
        <screen_id>#{session.page_ref.bytes.inject(:+)}</screen_id>
      </response>
    XML
    Rails.logger.info "MoovUssdController RESPONSE: #{xml}"
    render plain: xml
  end

  def instance
    @instance ||= Mese::Config.instance_by_name params['instance_name'] + '_bj'
  end
end
