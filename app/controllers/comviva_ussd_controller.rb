class ComvivaUssdController < UssdController

  def provider_key
    params[:provider_key]
  end

  def parse_ussd_params
    Rails.logger.info "ComvivaUssdController #notify: #{params.inspect}"

    ussd_params = {}
    ussd_params[:msisdn] = params['msisdn']
    ussd_params[:provider_session_id] = params['sessionID']
    ussd_params[:is_new_request] = params['isnewrequest']
    ussd_params[:raw_input] = params['input']
    ussd_params[:input] = [params['input']]
    ussd_params[:short_code] = params[:short_code]
    ussd_params[:network_code] = provider.details['network_code']

    ussd_params
  end

  private

  def render_response(msg:, final: false)
    response.headers['Freeflow'] = final ? 'FB' : 'FC'
    response.headers['charge'] = 'N'
    response.headers['amount'] = 0
    response.headers['cpRefId'] = ussd_params[:provider_session_id]

    Rails.logger.info "ComvivaUssdController #render_response: Session ID: #{ussd_params[:provider_session_id]} | Freeflow: #{response.headers['Freeflow']} | Body: #{msg}"
    render plain: msg
  end

end
