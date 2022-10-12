module Reportinator
  class AdditionStringFunction < StringFunction
    PREFIXES = ["!a"]

    def output
      values = body.split(",").map { |value| parse_value(value.strip) }
      values.map! { |subvalue| NumberStringFunction.parse("!n #{subvalue}") }
      values.sum(0)
    end
  end
end
