module Reportinator
  class StringArrayFunction < ArrayFunction
    PREFIXES = [">string"]

    def output
      values.prepend target
      values.map { |value| parse_value(value).to_s }.join
    end
  end
end
