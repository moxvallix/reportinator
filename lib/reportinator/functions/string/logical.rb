module Reportinator
  class LogicalStringFunction < StringFunction
    PREFIXES = ["@true", "@false", "@nil", "@null"]

    def output
      case prefix
      when "@true" then true
      when "@false" then false
      when "@nil", "@null" then nil
      else element
      end
    end
  end
end
