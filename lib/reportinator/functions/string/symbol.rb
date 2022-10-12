module Reportinator
  class SymbolStringFunction < StringFunction
    PREFIXES = [":"]

    def output
      body.to_sym
    end
  end
end
