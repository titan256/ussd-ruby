class EeaUssdController < UssdController
  def provider_key
    'eea'
  end

  def parse_ussd_params
    Rails.logger.info "GenericUssdController #notify: #{params.inspect}"
    ussd_params = {}
    ussd_params[:msisdn] = params['msisdn']
    ussd_params[:provider_session_id] = params['session_id']
    ussd_params[:raw_input] = params['user_input']
    ussd_params[:input] = [params['user_input']]
    ussd_params[:short_code] = params['short_code']

    # or get from provider?
    ussd_params[:network_code] = params['network_code']

    ussd_params
  end

  private

  def render_response(final: false, msg:)
    hash = {
      'state' => final ? 'FI' : 'CON',
      'msg' => msg
    }
    Rails.logger.info "GenericUssdController RESPONSE: #{hash}"
    render json: hash
  end

  def instance
    @instance ||= Mese::Config.instance_by_name params['instance_name']
  end
end
