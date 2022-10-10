module Reportinator
  class Parser < Base
    ESCAPE_VALUES = %w[: & # $ ! @ ?]

    def escape_value(value)
      return value unless value.is_a? String
      ESCAPE_VALUES.each do |escape|
        return value.prepend("?/") if value.strip.start_with?(escape)
      end
      value
    end
  end
end
