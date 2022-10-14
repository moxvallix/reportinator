module Reportinator
  class Function < Base
    attribute :element
    attribute :variables, default: {}

    def self.parse(element, variables = {})
      new(element: element, variables: variables).get
    end

    def parse_value(value)
      ValueParser.parse(value, variables)
    end

    def parse_and_execute_value(target, value)
      ValueParser.parse_and_execute(target, value, variables)
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
