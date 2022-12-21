module Reportinator
  class Function < Base
    attribute :element
    attribute :metadata, default: {}

    def self.parse(element, metadata = {})
      new(element: element, metadata: metadata).get
    end

    def parse_value(value, meta = {})
      parse_meta = merge_hash(metadata, meta)
      ValueParser.parse(value, parse_meta)
    end

    def parse_and_execute_value(target, value, meta = {})
      parse_meta = merge_hash(metadata, meta)
      ValueParser.parse_and_execute(target, value, parse_meta)
    end

    def prefixes
      self.class::PREFIXES
    end

    private

    def get_prefix(value)
      raise "Value is not a string" unless value.instance_of? String
      sorted_prefixes = prefixes.sort.reverse
      sorted_prefixes.each do |prefix|
        return prefix if value.start_with? prefix
      end
      raise "Value #{value} is incompatible with this function!"
    end
  end
end
