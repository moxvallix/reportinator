module Reportinator
  class Row < Base
    attr_writer :columns

    def columns
      @columns ||= []
    end

    def self.create(input)
      row = new
      if input.instance_of?(Array)
        input.each { |value| row.insert value }
      else
        row.insert(input)
      end
      row
    end

    def insert(data, position = :last)
      return insert_collection(data, position) if data.is_a?(Reportinator::Collection)
      column = create_column(data)
      return columns.prepend(column) if position == :first
      return columns.insert(position, column) if position.is_a? Numeric
      return columns.append(column) if position == :last
      raise "Invalid Position!"
    end

    def insert_collection(data, position = :last)
      raise "Not a collection!" unless data.is_a?(Reportinator::Collection)
      data.delimit.each do |row|
        row.each { |col| insert(col, position) }
      end
    end

    def total
      numeric_columns = columns.select { |c| c.numeric? }
      numeric_columns.sum { |c| c.output }
    end

    def output
      columns.map { |c| c.output }
    end

    private

    def create_column(data)
      Column.new(data: data)
    end
  end
end
