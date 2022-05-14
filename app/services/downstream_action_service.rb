class DownstreamActionService < HttpService

  def initialize instance:, session:, last_hop:, action:
    @action_key = action
    super instance: instance, session: session, last_hop: last_hop
  end

  def request_complete_url
    "#{@instance.base_url}/#{@action_key}/"
  end
  
  def request_body
    # also add the action name to the body
    body_hash = session_params.merge({"action" => @action_key})
    # hackhack to support PC who wants payment_amount in the dict
    # but yet momocontroller mush have amount
    payment_amount = body_hash['session_data']['payment_amount']
    if payment_amount
      if payment_amount.instance_of? String
        body_hash['session_data']['amount'] = payment_amount.tr('^0-9','')
      else
        body_hash['session_data']['amount'] = payment_amount
      end
    end
    body_hash.to_json
  end

  def results_data
    key = "#{@instance.name}_#{@action_key}_status"
    request_status = @response.status == 200 ? 'success' : 'error'
    action_status = @parsed_response['status'] || request_status
    { key => action_status }
  end

end
