module Reportinator
  class FlattenArrayFunction < ArrayFunction
    PREFIXES = [">flatten"]

    def output
      array = []
      array.append parse_value(target)
      array.append parse_value(values)
      array.flatten
    end
  end
end
