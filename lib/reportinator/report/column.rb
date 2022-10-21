module Reportinator
  class Column < Base
    OUTPUT_TYPES = {
      numeric: [Numeric],
      date: [Date, Time],
      string: [String],
      hash: [Hash],
      array: [Array]
    }

    attribute :data
    attr_writer :output

    def output
      @output ||= ReportParser.parse(data)
    end

    OUTPUT_TYPES.each do |type, classes|
      define_method(:"#{type}?") { classes.each { |c| return true if output.is_a? c }; false }
    end
  end
end
