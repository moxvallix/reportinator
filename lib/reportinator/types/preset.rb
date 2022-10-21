module Reportinator
  class PresetReport < ReportType
    attribute :values

    def data
      split_values.map { |row| Row.create(row) }
    end

    def split_values
      data = values.instance_of?(Array) ? values : [values]
      rows = []
      temp = []
      data.each do |col|
        if col.instance_of?(Array)
          rows << temp unless temp.empty?
          temp = []
          rows << col
        else
          temp << col
        end
      end
      rows << temp unless temp.empty?
      rows
    end
  end
end
