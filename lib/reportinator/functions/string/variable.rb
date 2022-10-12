module Reportinator
  class VariableStringFunction < StringFunction
    PREFIXES = ["$"]

    def output
      return element unless variables.include? body.to_sym
      variables[body.to_sym]
    end
  end
end
