module Reportinator
  class RepeatArrayFunction < ArrayFunction
    PREFIXES = [">repeat"]

    def output
      count = parse_value((target.instance_of?(String) ? target.strip : target))
      return "Invalid count" unless count.is_a? Numeric
      output = Reportinator::Collection.new
      count.times do |iteration|
        target = parse_iteration(iteration + 1, count)
        parse_meta = merge_hash(metadata, {variables: {target: target, total: count}})
        output << Reportinator::SnippetArrayFunction.parse([">snippet", values[0], values[1]], parse_meta)
      end
      output
    end

    def parse_iteration(iteration, total)
      return iteration unless values[2].present?
      parse_value(values[2], variables: {target: iteration, total: total})
    end
  end
end