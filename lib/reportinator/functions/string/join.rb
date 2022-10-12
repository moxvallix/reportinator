module Reportinator
  class JoinStringFunction < StringFunction
    PREFIXES = ["!j"]

    def output
      values = body.split(",").map { |value| parse_value(value.strip) }
      values.join(" ")
    end
  end
end
