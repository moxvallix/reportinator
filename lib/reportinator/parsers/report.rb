module Reportinator
  class ReportParser < Parser
    attribute :element
    attribute :data

    def self.parse(element, data = nil)
      set_data = (data.present? ? data : element)
      new(element: element, data: set_data).output
    end

    def output
      return parse_array if element_class == Array
      return parse_hash if element_class == Hash
      return parse_string if element_class == String
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

    def parse_string
      raise "Not a string" unless element_class == String
      return element unless element.strip.start_with?("?")
      return element.sub("?/", "") if element.strip.start_with?("?/")
      # return parse_row_total if element.start_with?("?tr")
      # return parse_column_total if element.start_with?("?tc")
      element
    end

    def element_class
      element.class
    end

    private

    def parse_value(value)
      self.class.parse(value, data)
    end
  end
end
