require 'typhoeus'
require 'typhoeus/adapters/faraday'

module Mese
  class Http
    ###
    # wrap the http wrapper
    #
    # Usage:
    #
    # h = Mese::Http.new :get, 'https://hallo.com' - immediately makes a request
    #

    attr_reader :response, :error

    def initialize http_verb, url, body: nil, headers: {}, timeout: 10, ssl_options: false, adapter: :net_http
      begin
        connection = Faraday.new(ssl: ssl_options) do |faraday|
          faraday.request  :url_encoded
          faraday.adapter  adapter
        end

        request_block = ->(request) do
          request.headers = headers
          request.options.timeout = timeout
          request.body = body
        end

        @response = connection.send http_verb, url, &request_block
      rescue => e
        @error = e
      end
    end

    def success?
      error.nil? && response&.success?
    end

    def timeout?
      error.is_a? Faraday::TimeoutError
    end

    def error?
      error.present?
    end

    def response_status
      response.try :status
    end

    def response_body
      response.try :body
    end

    def error_message
      error.try :message
    end

    def error_backtrace
      error.try :backtrace
    end

    %i(get post).each do |verb|
      define_singleton_method "#{verb}!" do |*args|
        new *args.unshift(verb)
      end
    end
  end
end
