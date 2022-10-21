module Reportinator
  class ValueParser < Parser
    attribute :element
    attribute :variables, default: {}

    def self.parse(element, variables = {})
      variables = variables.present? ? variables : {}
      new(element: element, variables: variables).output
    rescue
      "Parsing Error"
    end

    def self.parse_and_execute(target, values, variables = {})
      parsed_target = target
      if target.instance_of?(String)
        parsed_target = parse(target, variables)
      end
      parsed_values = parse(values, variables)
      MethodParser.parse(parsed_target, parsed_values)
    end

    def output
      config.configured_functions.each do |function|
        return function.parse(element, variables) if function.accepts? element
      end
      return parse_array if element_class == Array
      return parse_hash if element_class == Hash
      element
    end

    def parse_array
      raise "Not an array" unless element_class == Array
      element.map { |value| parse_value(value) }
    end

    def parse_hash
      raise "Not a hash" unless element_class == Hash
      element.transform_values { |value| parse_value(value) }
    end

    def element_class
      element.class
    end

    def parse_value(value)
      self.class.parse(value, variables)
    end
  end
end
