module Reportinator
  class JoinArrayFunction < ArrayFunction
    PREFIXES = ["+"]

    def output
      joiner = ValueParser.parse(target, variables)
      joiner = (joiner.instance_of?(String) ? joiner : target)
      values.map { |value| parse_value(value) }.join(joiner)
    end
  end
end
