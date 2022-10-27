module Reportinator
  class ModelReport < ReportType
    include Helpers

    PARSE_PARAMS = false
    attr_accessor :metadata
    attribute :target
    attribute :method_list, default: []

    validates :target, presence: true

    def data
      self.target = ValueParser.parse(target, metadata)
      return Row.create(get_model_data(target)) unless target.respond_to? :to_ary
      records_data.map { |data| Row.create(data) }
    end

    def records_data
      output = []
      target.each do |model|
        value = get_model_data(model)
        output << value
      end
      output
    end

    def get_model_data(target)
      method_list.map do |method|
        parse_method(target, method)
      end
    end

    def parse_method(target, method)
      puts "input: #{method}"
      parser_metadata = (metadata.present? ? metadata : {})
      parser_metadata = merge_hash(parser_metadata, {variables: {target: target}})
      parsed_method = ValueParser.parse(method, parser_metadata)
      return parsed_method if parsed_method.instance_of? String
      MethodParser.parse(target, parsed_method)
    end
  end
end
