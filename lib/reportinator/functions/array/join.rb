module Reportinator
  class JoinArrayFunction < ArrayFunction
    PREFIXES = [">join"]

    def output
      joiner = parse_value(target)
      joiner = (joiner.instance_of?(String) ? joiner : target)
      values.map { |value| parse_value(value) }.join(joiner)
    end
  end
end
