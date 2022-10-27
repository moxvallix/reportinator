module Reportinator
  class Function < Base
    attribute :element
    attribute :metadata, default: {}

    def self.parse(element, metadata = {})
      new(element: element, metadata: metadata).get
    end

    def parse_value(value)
      ValueParser.parse(value, metadata)
    end

    def parse_and_execute_value(target, value)
      ValueParser.parse_and_execute(target, value, metadata)
    end

    def prefixes
      self.class::PREFIXES
    end

    private

    def get_prefix(value)
      raise "Value is not a string" unless value.instance_of? String
      sorted_prefixes = prefixes.sort.reverse
      sorted_prefixes.each do |prefix|
        return prefix if value.start_with? prefix
      end
      raise "Value #{value} is incompatible with this function!"
    end
  end
end
