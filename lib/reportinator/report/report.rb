module Reportinator
  class Report < Base
    attr_writer :rows

    def rows
      @rows ||= []
    end

    def insert(row, position = :last)
      return insert_row(row, position) if row.instance_of? Row
      raise "Invalid row data: #{row}" unless row.instance_of? Array
      row.each { |r| insert_row(r) }
    end

    def insert_row(row, position = :last)
      raise "Not a row" unless row.instance_of? Row
      return rows.append(row) if position == :last
      return rows.prepend(row) if position == :first
      return rows.insert(position, row) if position.is_a? Numeric
      raise "Invalid Position!"
    end

    def output
      rows.map { |r| r.output }
    end
  end
end