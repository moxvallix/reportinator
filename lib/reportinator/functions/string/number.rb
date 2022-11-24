module Reportinator
  class NumberStringFunction < StringFunction
    PREFIXES = ["!n", "!nf", "!ni"]

    attr_writer :parsed_body

    def output
      return parse_float if prefix == "!nf"
      return parse_integer if prefix == "!ni"
      parse_number
    end

    def parsed_body
      to_parse = body
      to_parse.strip! if to_parse.instance_of? String
      @parsed_body ||= parse_value(body).to_s
    end

    def parse_float
      parsed_body.to_f
    end

    def parse_integer
      parsed_body.to_i
    end

    def parse_number
      float = (parsed_body =~ /\d\.\d/)
      return parse_float if float.present?
      parse_integer
    end
  end
end
