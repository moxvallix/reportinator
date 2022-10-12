module Reportinator
  class ConstantStringFunction < StringFunction
    PREFIXES = ["&"]

    def output
      body.constantize
    end
  end
end
