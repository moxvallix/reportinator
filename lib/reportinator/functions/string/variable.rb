module Reportinator
  class VariableStringFunction < StringFunction
    PREFIXES = ["$"]

    def output
      variables = metadata[:variables]
      variable = body.to_sym
      return element unless variables.present? && variables.include?(variable)
      variables[variable]
    end
  end
end
