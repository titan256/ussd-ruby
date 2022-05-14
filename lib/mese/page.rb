module Mese
  class Page
    attr_reader :instance, :page_ref, :page_hash

    def initialize instance, page_ref,  page_hash
      @page_ref = page_ref
      @instance = instance
      #TODO: break this into methods and fields
      @page_hash = page_hash
    end

    def final?
      @page_hash['final']
    end

    def render_tmp template, context
      ERB.new(template).result_with_hash(context)
    end

    def render context
      # TODO: ERB is too powerful for this,
      # big security risk
      ERB.new(@page_hash['template']).result_with_hash(context)
    end

    def process! last_input, session
      # if any session variables defined, add them here
      if not @page_hash['session_variable'].nil?
        session.data[@page_hash['session_variable']] = last_input
      end

      if not @page_hash['session_variables'].nil?
        @page_hash['session_variables'].each do |k, v|
          # should check if v is a has first
          if v[last_input].nil?
            sess_tmpl = v['*']
          else
            sess_tmpl = v[last_input]
          end
          if sess_tmpl.is_a? String
            sess_val = render_tmp sess_tmpl, session.data
          else
            sess_val = sess_tmpl
          end
          session.data[k] = sess_val
        end
      end

      return if @page_hash['final']

      next_page_ref = get_next_page @page_hash['next_pages'], last_input, session
      session.page_ref = next_page_ref
      next_page = @instance.get_page next_page_ref
      return next_page
    end

    def get_next_page next_pages_hash, last_input, session
      Rails.logger.info("Mese::Page Starting routing for #{next_pages_hash} with data #{session.data}")
      # can get next page based on value of some session variable
      # if key is not defined, assume to be last_input
      comparison_key = next_pages_hash['key']
      comparison_value = comparison_key.nil? ? last_input : session.data.dig(comparison_key)
      Rails.logger.info("Mese::Page Comparison key #{comparison_key} comparison value #{comparison_value}")
      # allow regexp keys
      # no don't allow regexp keys
      # matching_key = next_pages_hash.keys.select {|key| comparison_value.match(Regexp.new(key.gsub(/\*/, '.*')))}.first
      # next_page_def = next_pages_hash[matching_key]
      next_page_def = next_pages_hash[comparison_value]
      if next_page_def.nil?

        # if not able to find next page by above, check for a default
        next_page_def = next_pages_hash['*']

        # if no default, go to invalid page
        if next_page_def.nil?
          next_page_def = 'invalid_input'
        end
      end

      Rails.logger.info("Mese::Page Getting next page with def #{next_page_def}")
      # next page def anc be a string (directly referring to a page)
      # or a hash, which may contain some action configuration
      if next_page_def.is_a? String
        if next_page_def == '#previous'
          next_page_id = session[:previous_page]
        else
          next_page_ref = render_tmp next_page_def, session.data
        end
      else
        if next_page_def['validation']
          Rails.logger.info("Mese::Page Starting validation with #{next_page_def['validation']}, with session data #{session.data}")
          session.data['validation_result'] = render_tmp next_page_def['validation'], session.data
          Rails.logger.info("Mese::Page Validation result #{session.data['validation_result']}")
          next_page_ref = get_next_page(next_page_def['next_pages'], last_input, session)
        elsif next_page_def['instance'] and next_page_def['action']
          Rails.logger.info("Mese::Page Performing action #{next_page_def['action']}")
          # TODO: actually run the service somewhere else
          # this is not really the right place
          service = DownstreamActionService.new session: session, 
            instance: Mese::Config.instance_by_name(next_page_def['instance']), 
            last_hop: session.last_hop,
            action: next_page_def['action']
          service.perform!
          session.data = session.data.merge(service.new_session_data)
          session.data = session.data.merge(service.results_data)
          # nested next_pages! recurse
          Rails.logger.info("Mese::Page New session data #{service.new_session_data} results data #{service.results_data}")
          next_page_ref = get_next_page(next_page_def['next_pages'], last_input, session)
        elsif next_page_def['instance']
          # allow switching between forward and self rendered
          # not currently supported
        elsif next_page_def['next_page']
          next_page_ref = next_page_def['next_page']
        end
      end
      Rails.logger.info("Mese::Page Next page ref result #{next_page_ref}")
      next_page_ref
    end

    def to_s
      page_ref
    end
  end
end
