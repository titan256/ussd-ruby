module Mese
  class Config
    FILE = "#{Rails.root}/config/settings.yml"

    class << self
      def instances
        @instances ||= build_instances
      end

      def instance_by_name name
        instances.find { |i| i.name == name }
      end

      def providers
        build_instances unless instances
        @providers ||= build_providers
      end

      def provider_by_key provider_key
        providers.find { |p| p.key == provider_key.to_s }
      end

      def all_provider_keys
        providers.map(&:provider_keys).flatten
      end

      def get_shared_page page_ref
        shared_pages.find { |p| p.page_ref == page_ref }
      end
      
      def shared_pages
        @shared_pages ||= config_hash[:pages][:shared]&.map do |page_ref, page_hash|
          Mese::Page.new(nil, page_ref, page_hash)
        end
      end

      private

      def config_hash
        @config_hash ||= YAML.load_file(Mese::Config::FILE).with_indifferent_access
      end

      def build_instances
        config_hash[:instances].map do |i_name, i_details|
          Mese::Instance.new(i_name, i_details, config_hash[:pages][i_name])
        end
      end

      def build_providers
        config_hash[:providers].map do |p_name, p_details|
          Mese::Provider.new(p_name, p_details)
        end.flatten
      end

    end
  end
end
