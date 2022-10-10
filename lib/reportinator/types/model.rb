module Reportinator
  class ModelReport < Report
    attribute :target
    attribute :method_list, default: []

    validates :target, presence: true

    def data
      return get_model_data(target) unless target.methods.include? :first
      records_data
    end

    def records_data
      records = target
      records = target.all if target.methods.include? :all
      output = []
      records.each do |model|
        value = get_model_data(model)
        output << value
      end
      output
    end

    def get_model_data(target)
      parsed_target = ValueParser.parse(target)
      method_list.map do |method|
        parse_method(parsed_target, method)
      end
    end

    def parse_method(target, method)
      parsed_method = ValueParser.parse(method)
      return parsed_method if parsed_method.class == String
      MethodParser.parse(target, parsed_method)
    end
  end
end
