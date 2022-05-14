module Mese
  class Instance
    attr_reader :name, :base_url, :template_method, :api_key

    def initialize name, details_hash, pages_arr
      @name = name
      @base_url = details_hash[:base_url]
      @api_key = details_hash[:api_key]
      @template_method = details_hash[:template_method]&.to_sym || :forward
      @configured_pages = build_pages pages_arr || []
    end

    def forward_templates?
      @template_method == :forward
    end

    def configured_templates?
      @template_method == :configured
    end

    def build_pages pages_arr
      pages_arr&.map do |page_ref, page_hash|
        Mese::Page.new(self, page_ref, page_hash)
      end
    end

    def get_page page_ref
      @configured_pages.find { |p| p.page_ref == page_ref }
    end

    alias to_s name

    def shadowed_api_key
      key_str = api_key.to_s
      if key_str.length > 10
        "#{key_str[0..3]}#{'x' * (key_str.length - 5)}#{key_str[-3, -1]}"
      else
        "#{key_str[0]}#{'x' * key_str.length}"
      end
    end
  end
end
