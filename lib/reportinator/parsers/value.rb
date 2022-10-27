module Reportinator
  class ValueParser < Parser
    attribute :element
    attribute :metadata, default: {}

    def self.parse(element, metadata = {})
      metadata = metadata.present? ? metadata : {}
      new(element: element.dup, metadata: metadata).output
    rescue
      "Parsing Error"
    end

    def self.parse_and_execute(target, values, metadata = {})
      parsed_target = target
      if target.instance_of?(String)
        parsed_target = parse(target, metadata)
      end
      parsed_values = parse(values, metadata)
      MethodParser.parse(parsed_target, parsed_values)
    end

    def output
      config.configured_functions.each do |function|
        return function.parse(element, metadata) if function.accepts? element
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
      self.class.parse(value, metadata)
    end
  end
end
