class UssdController < ApplicationController

  def notify
    ActiveRecord::Base.connection_pool.with_connection do
      hop_log = save_hop
    end

    raise 'ussd_params must have all required keys' unless validate_ussd_params

    response_text, final = drive_session
    ActiveRecord::Base.connection_pool.with_connection do
      #if final
      #  session.closed_at = Time.zone.now
      #end

      # save the session to capture next page, session data changes, and closed
      session.save

      hop_log = save_hop
      if response_text
        hop_log.response = response_text
        hop_log.save
      end
    end
    render_response final: final, msg: response_text
  end

  private

  #TOOO: duplicated in lib/mese/page.rb
  def render_tmp template, context
    ERB.new(template).result_with_hash(context)
  end

  def ussd_params
    @ussd_params ||= parse_ussd_params
  end

  def validate_ussd_params
    required_keys = %i[provider_session_id short_code input msisdn]
    required_keys.all? { |key| @ussd_params.key? key }
  end

  def parse_ussd_params
    # this method must populate
    # provider_session_id
    # short_code
    # input
    # msisdn
    raise NotImplementedError, 'must be implemented by subclasses'
  end

  def session
    @session ||= find_or_create_session ussd_params[:provider_session_id]
  end

  def instances
    @instances ||= provider.find_route ussd_params[:short_code], ussd_params[:msisdn]
  end

  def provider
    #implementing classes need to set provider_key
    @provider ||= Mese::Config.provider_by_key provider_key
  end


  def find_or_create_session session_id
    session = Session.find_by(provider_session_id: ussd_params[:provider_session_id], provider_key: provider_key)
    if not session
      session = Session.new(msisdn: ussd_params[:msisdn],
                            provider_key: provider_key,
                            provider_session_id: session_id,
                            short_code: ussd_params[:short_code],
                            network_code: ussd_params[:network_code],
                            data:{})
      session.save()
    end

    session
  end

  def save_hop
    hop_log = Hop.create(session: session, input: ussd_params[:raw_input])
  end

  def drive_session
    for instance in instances
      if instance.forward_templates?
        # if templates rendered by downstream, forward
        # and check success;
        # if success, render the message
        # if not, try the next instance
        success, w = forward_to_instance instance
        if success
          msg = w.response_text
          final = w.final
          session.data = session.data.merge(w.new_session_data)
          return msg, final
        end
      else
        # if hardcoded templates, render internally
        # ( and don't need to check other instances)
        return process_input instance
      end
    end

    # no instance was able to hande the request, 
    # render a generic error
    msg = get_generic_error.render session.data
    final = true
    return msg, final
  end

  def process_input instance
    if session.page_ref
      #TODO: better error for invalid page_ref
      current_page = instance.get_page session.page_ref
      for last_input in ussd_params[:input] do
        #TODO: properly handle multi input
        next_page = current_page.process! last_input, session
      end
    else
      next_page = instance.get_page 'start_page'
      session.page_ref = next_page&.to_s
      #session.save
    end

    if not next_page
      #routing error...return generic error
      generic_error = get_generic_error(instance: instance)
      msg = generic_error.render session.data
      final = true
    else
      msg = next_page.render session.data
      final = next_page.final?
    end

    return msg, final
  end

  def get_generic_error instance: nil
    # if instance has a generic error page configured, use it
    instance&.get_page('error') || Mese::Config.get_shared_page('error')
  end

  def forward_to_instance instance
    w = ForwardToDownstreamService.new(
      instance: instance,
      session: session,
      last_hop: session.last_hop
    )
    success = w.perform!
    return success, w
  end
end
