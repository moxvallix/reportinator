module Reportinator
  class RangeStringFunction < StringFunction
    PREFIXES = ["!r", "!rd", "!rn"]

    def output
      values = body.split(",").map { |value| parse_value(value.strip) }
      case prefix
      when "!rn" then values.map! { |subvalue| NumberStringFunction.parse("!n #{subvalue}") }
      when "!rd" then values.map! { |subvalue| DateStringFunction.parse("!d #{subvalue}") }
      end
      Range.new(*values)
    end
  end
end
