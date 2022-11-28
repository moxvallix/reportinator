module Reportinator
  class ModelReport < ReportType
    include Helpers
    PARSE_PARAMS = false
    attribute :target
    attribute :method_list, default: []

    validates :target, presence: true

    def data
      self.target = ValueParser.parse(target, metadata, false)
      return Row.create(get_model_data(target)) unless target.respond_to? :each
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
      parser_metadata = merge_hash(metadata, {variables: {target: target}})
      parsed_method = ValueParser.parse(method, parser_metadata)
      return parsed_method if parsed_method.instance_of? String
      MethodParser.parse(target, parsed_method)
    end
  end
end
