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
      method_list.map do |method|
        ValueParser.parse_and_execute(target, method)
      end
    end
  end
end
