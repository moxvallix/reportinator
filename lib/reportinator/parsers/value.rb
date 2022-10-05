module Reportinator
  class ValueParser < Base
    VALUE_FUNCTIONS = %i[a d i r]

    attribute :element
    attribute :variables, default: {}

    def self.parse(element, variables = {})
      variables = variables.present? ? variables : {}
      new(element: element, variables: variables).output
    end

    def self.parse_and_execute(target, values, variables = {})
      parsed_target = target
      if target.instance_of?(String)
        parsed_target = new(element: target, variables: variables).parse_string
      end
      parsed_values = parse(values, variables)
      MethodParser.parse(parsed_target, parsed_values)
    end

    def output
      return parse_array if element_class == Array
      return parse_hash if element_class == Hash
      return parse_string if element_class == String
      element
    end

    def parse_array
      raise "Not an array" unless element_class == Array
      front = element[0]
      return parse_executed_array if front.instance_of?(String) && front.start_with?("#")
      element.map { |value| parse_value(value) }
    end

    def parse_executed_array
      raise "Not an executable array" unless element[0].start_with?("#")
      values = element
      target = values.delete_at(0).sub("#", "")
      parse_and_execute_value(target, values)
    end

    def parse_hash
      raise "Not a hash" unless element_class == Hash
      element.transform_values { |value| parse_value(value) }
    end

    def parse_string
      raise "Not a string" unless element_class == String
      return element.sub(":", "").to_sym if element.start_with?(":")
      return element.sub("&", "").constantize if element.start_with?("&")
      return parse_variable(element) if element.start_with?("$")
      return parse_function(element) if element.start_with?("!")
      element
    end

    def element_class
      element.class
    end

    private

    def parse_variable(value)
      key = value.sub("$", "").to_sym
      variables[key]
    end

    def parse_function(value)
      input = value.strip
      function = function_type(input)
      return value unless function.present?
      input.sub!(function_prefix(function), "")
      case function
      when :a then addition_function(input)
      when :d then date_function(input)
      when :i then integer_function(input)
      when :r then range_function(input)
      else value
      end
    end

    def function_type(value)
      VALUE_FUNCTIONS.each do |function|
        return function if value.start_with?(function_prefix(function))
      end
      false
    end

    def function_prefix(function)
      "!#{function}"
    end

    def addition_function(value)
      values = value.split(",").map { |subvalue| parse_value(subvalue.strip) }
      if values.first.instance_of?(Integer)
        values.map! { |value| value.to_i }
        values.sum(0)
      else
        values.sum("")
      end
    rescue
      0
    end

    def date_function(value)
      Time.parse(value)
    rescue
      Time.now
    end

    def integer_function(value)
      value.to_i
    rescue
      0
    end

    def range_function(value)
      values = value.split(",").map { |value| parse_value(value.strip) }
      Range.new(*values)
    rescue
      Range(0..1)
    end

    def parse_value(value)
      self.class.parse(value, variables)
    end

    def parse_and_execute_value(target, value)
      self.class.parse_and_execute(target, value, variables)
    end
  end
end
