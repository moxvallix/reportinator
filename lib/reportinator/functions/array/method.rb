module Reportinator
  class MethodArrayFunction < ArrayFunction
    PREFIXES = ["#"]

    def output
      parse_and_execute_value(target, values)
    end
  end
end
