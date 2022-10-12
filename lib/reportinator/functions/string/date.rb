module Reportinator
  class DateStringFunction < StringFunction
    PREFIXES = ["!d"]

    def output
      Time.parse(body)
    end
  end
end
