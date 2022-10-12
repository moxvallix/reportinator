module Reportinator
  class NumberStringFunction < StringFunction
    PREFIXES = ["!n"]

    def output
      float = (body =~ /\d\.\d/)
      return body.to_f if float.present?
      body.to_i
    end
  end
end
