module Reportinator
  class RangeArrayFunction < ArrayFunction
    PREFIXES = [">range"]

    def output
      start_value = parse_value(target)
      end_value = parse_value(values[0])
      (start_value..end_value)
    end
  end
end
