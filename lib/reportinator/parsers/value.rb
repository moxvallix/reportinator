module Reportinator
  class ValueParser < Parser
    VALUE_FUNCTIONS = %i[a d n j rn rd r]

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
      return escape_value(parse_string) if element_class == String
      element
    end

    def parse_array
      raise "Not an array" unless element_class == Array
      front = element[0]
      return parse_executed_array if front.instance_of?(String) && front.start_with?("#")
      return parse_joined_array if front.instance_of?(String) && front.start_with?("+")
      element.map { |value| parse_value(value) }
    end

    def parse_executed_array
      raise "Not an executable array" unless element[0].start_with?("#")
      values = element
      target = values.delete_at(0).sub("#", "")
      return parse_and_execute_value(target, values) if target.present?
      if values.count > 1
        target = values.delete_at(0)
        parse_and_execute_value(target, values)
      else
        element
      end
    end

    def parse_joined_array
      raise "Not a joinable array" unless element[0].start_with?("+")
      values = element
      joiner = values.delete_at(0).sub("+", "")
      joiner = values.delete_at(0) if values.count > 1 && joiner.empty?
      parsed_joiner = parse_value(joiner)
      parsed_joiner = (parsed_joiner.instance_of?(String) ? parsed_joiner : joiner)
      values.map { |value| parse_value(value) }.join(parsed_joiner)
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
      return parse_logical(element) if element.start_with?("@")
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
      output = run_function(function, input)
      output.nil? ? value : output
    end

    def parse_logical(value)
      input = value.sub("@", "").strip
      case input
      when "true" then true
      when "false" then false
      when "nil", "null" then nil
      else value
      end
    end

    def run_function(function, input)
      case function
      when :a then addition_function(input)
      when :d then date_function(input)
      when :n then number_function(input)
      when :r then range_function(input)
      when :j then join_function(input)
      when :rn then range_function(input, :number)
      when :rd then range_function(input, :date)
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
      values = parse_function_array(value)
      values.map! { |value| number_function(value) }
      values.sum(0)
    rescue
      0
    end

    def date_function(value)
      Time.parse(value)
    rescue
      Time.now
    end

    def number_function(value)
      float = (value =~ /\d\.\d/)
      return value.to_f if float.present?
      value.to_i
    rescue
      0
    end

    def range_function(value, type = :any)
      values = parse_function_array(value)
      case type
      when :number then values.map! { |subvalue| number_function(subvalue) }
      when :date then values.map! { |subvalue| date_function(subvalue) }
      end
      Range.new(*values)
    rescue
      Range(0..1)
    end

    def join_function(value)
      values = parse_function_array(value)
      values.join(" ")
    end

    def parse_function_array(value, strip = true)
      value.split(",").map { |value| parse_value(strip ? value.strip : value) }
    end

    def parse_value(value)
      self.class.parse(value, variables)
    end

    def parse_and_execute_value(target, value)
      self.class.parse_and_execute(target, value, variables)
    end
  end
end
