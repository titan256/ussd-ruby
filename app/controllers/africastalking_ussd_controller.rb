class AfricastalkingUssdController < UssdController
  before_action :authenticate

  def provider_key
    'africastalking'
  end

  def parse_ussd_params
    Rails.logger.info "AfricastalkingUssdController #notify: #{params.inspect}"
    ussd_params = {}
    ussd_params[:msisdn] = params['phoneNumber']
    ussd_params[:provider_session_id] = params['sessionId']
    ussd_params[:raw_input] = params['text']
    ussd_params[:input] = [params['text'].split('*').last]
    ussd_params[:short_code] = params['serviceCode']&.strip
    ussd_params[:network_code] = params['networkCode']&.to_i

    ussd_params
  end

  private

  def render_response(final: false, msg:)
    # AT wants all responses to be prefixed with CON to continue the session
    # or END to end it
    prefix = final ? 'END' : 'CON'
    Rails.logger.info "AfricastalkingUssdController RESPONSE: #{prefix} #{msg}"
    render plain: "#{prefix} #{msg}"
  end

  def authenticate
    params['api_key'] == '0WaMKXlU224RPx31m748ECFGVcMys5BlC8LMGRprCRc'
  end

end
