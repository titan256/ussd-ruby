module Mese
  class Provider
    attr_reader  :key, :name, :brand, :country,
                 :testing, :details, :routes, :auth

    def initialize name, props = {}
      @key = name

      # will need this stuff later...
      @details = props[:details] || {}
      @auth = props[:auth] || {}
      @aggregates_for = props[:aggregates_for] || []

      # build routes
      @routes = Hash(props[:routing]).map do |short_code, routing_details|
        if routing_details.is_a?(String) || routing_details.is_a?(Array)
          Route.new provider: self, short_code: short_code,
                    instance_names: Array(routing_details)
        else
          raise "routing details must be Hash or Array but is #{routing_details.inspect}"
        end
      end.flatten

      raise "Routes are not uniq for Provider #{@name}" if @routes.count != @routes.uniq.count
    end

    def find_route short_code, msisdn
      # TODO what if no route
      routes = @routes.find do |r|
        r.short_code == short_code || r.short_code == msisdn
      end

      if routes.nil?
        msg = "No route for #{short_code}"
        Rails.logger.error(msg)
        raise msg
      else
        return routes.instances
      end
    end

    def to_s
      "Provider #{key}"
    end

  end
end
