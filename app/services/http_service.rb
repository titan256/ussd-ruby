class HttpService
  # base class for services with send a request to a configured downstream instance

  def initialize instance:, session:, last_hop:
    @instance = instance
    @session = session
    @last_hop = last_hop
  end

  def perform!
    # make sure db connections are released from the pool
    # before making a potentially long http request
    ActiveRecord::Base.clear_active_connections!
    http_service = Mese::Http.post! request_complete_url,
                                     headers: request_header,
                                     body: request_body

    #TODO better logging
    Rails.logger.info "Outgoing request #{request_complete_url} Headers: #{request_header} Body: #{request_body}"

    @response = http_service.response
    @parsed_response = begin
      JSON.parse((@response&.body.presence || '{}'))
    rescue JSON::ParserError => e
      Rails.logger.warn "#{self.class} - Request: #{request_complete_url} Could not parse response body: #{@response&.body}"
      {}
    end

    Rails.logger.info "#{self.class}- Request: #{request_complete_url} Response: #{@response.status} Body: #{@parsed_response}"
    if http_service.timeout?
      Rails.logger.info "#{self.class}- Request: #{request_complete_url} Timed out"
    elsif http_service.error?
      Rails.logger.info "#{self.class}- Request: #{request_complete_url} error"
      return false
    elsif http_service.response_status == 404
      Rails.logger.info "#{self.class}- Request: #{request_complete_url} rejected"
      return false
    elsif http_service.response_status == 0
      "Status code 0: #{@response.reason_phrase}"
    else
      "Weird Status - #{http_service.response_status} - #{http_service.response_body}"
    end

    true
  end

  def new_session_data
    @parsed_response['session_data'] || {}
  end

  private

  def request_complete_url
    @instance['base_url']
  end

  def request_header
    key_name = @instance.name == 'power_corner' ? 'X-API-KEY' : 'API-KEY'
    {  key_name => @instance.api_key, 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
  end

  def session_params
    # these are the parameters that will be sent in any downstream request
    # each implemtenting service might add a few more
    {
      "session_id" => @session.id,
      "msisdn" => @session.msisdn,
      "page_ref" => @session.page_ref,
      "session_data"  => @session.data,
      "serviceCode" => @session.short_code,
      "networkCode" => @session.network_code,
      "short_code" => @session.short_code,
      "network_code" => @session.network_code,
      "input" => @last_hop&.input,
    }
  end
end
