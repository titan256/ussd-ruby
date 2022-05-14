module Mese
  class Route

    include Comparable
    attr_reader :provider, :instances, :short_code

    def initialize provider:, instance_names:, short_code:
      @provider = provider

      @instances = instance_names.map { |n| ::Mese::Config.instance_by_name n }
      raise "not all instances found for #{instance_names}" unless @instances.compact.count == instance_names.count

      @short_code = short_code
    end

    def to_s
      "ROUTE FROM #{provider.key} CODE #{short_code || 'any'} => #{instances_to_s}"
    end

    def first_instance
      instances.first
    end

    def single_instance?
      instances.count == 1
    end

    def multi_instance?
      !single_instance?
    end

    def instances_to_s
      instances.map(&:to_s).join(',')
    end

  end
end
