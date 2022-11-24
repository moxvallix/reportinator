module Reportinator
  class HelperArrayFunction < ArrayFunction
    PREFIXES = [">strf", ">offset", ">title", ">sum"]

    INTERVALS = {
      days: {start: "at_beginning_of_day", end: "at_end_of_day"},
      weeks: {start: "at_beginning_of_week", end: "at_end_of_week"},
      months: {start: "at_beginning_of_month", end: "at_end_of_month"},
      years: {start: "at_beginning_of_year", end: "at_end_of_year"}
    }

    attr_writer :parsed_target, :parsed_values

    def output
      return parse_strftime if prefix == ">strf"
      return parse_offset if prefix == ">offset"
      return parse_title if prefix == ">title"
      return parse_sum if prefix == ">sum"
      element
    end

    def target_to_time
      parsed_target.to_s.to_time
    end

    def parse_strftime
      time = target_to_time
      return "Invalid Time" if time.nil?
      return "Invalid Format" unless parsed_values[0].instance_of? String
      time.strftime parsed_values[0]
    end

    def parse_offset
      time = target_to_time
      return "Invalid Time" if time.nil?
      offset = parsed_values[0]
      return "Missing Offset" unless offset.present?
      interval = parsed_values[1]
      snap = parsed_values[2]
      calculate_offset(time, offset, interval, snap)
    end

    def calculate_offset(time, offset, interval, snap)
      interval = (interval.present? ? interval : :months)
      interval = interval.to_s.pluralize.to_sym
      return "Invalid Interval" unless INTERVALS.include? interval
      interval_data = INTERVALS[interval]
      snap = false unless interval_data.include? snap
      output = time.advance({interval => offset})
      output = output.send(interval_data[snap]) if snap.present?
      output
    end

    def parse_title
      to_join = [parsed_target] + parsed_values
      to_join.join(" ").titleize
    end

    def parse_sum
      sum_values = parsed_values.append parsed_target
      sum_values.sum { |value| parse_value("!n #{value}") }
    end

    def parsed_target
      @parsed_target ||= parse_target
    end

    def parse_target
      formatted_target = (target.instance_of?(String) ? target.strip : target)
      parse_value(formatted_target)
    end

    def parsed_values
      @parsed_values ||= values.map { |value| parse_value(value) }
    end
  end
end
