module Reportinator
  class Parser < Base
    cattr_writer :prefix_list

    def self.get_prefix_list
      config.configured_functions.map { |function| function::PREFIXES }.flatten
    end

    def self.prefix_list
      @prefix_list ||= get_prefix_list
    end

    def prefix_list
      self.class.prefix_list
    end

    def escape_value(value)
      return value unless value.is_a? String
      prefix_list.each do |escape|
        return value.prepend("?/") if value.strip.start_with?(escape)
      end
      value
    end
  end
end
