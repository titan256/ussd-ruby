class ForwardToDownstreamService < HttpService

  def request_complete_url
    @instance.base_url
  end
  
  def request_body
    #nothing to add to the basic session params
    session_params.to_json
  end

  def final
    @parsed_response['final']
  end

  def response_text
    @parsed_response['response']
  end
end
