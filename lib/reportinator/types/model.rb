module Reportinator
  class ModelReport < Report
    attribute :target
    attribute :method_list, default: []

    validates :target, presence: true

    def data
      return get_model_data(target) unless target.respond_to? :to_ary
      records_data
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
      return method if method.instance_of?(String)
      MethodParser.parse(target, method)
    end
  end
end
