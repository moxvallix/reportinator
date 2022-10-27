module Reportinator
  class ReportType < Base
    PARSE_PARAMS = true

    attribute :title

    def self.generate(params)
      output = {}
      params.each do |key, value|
        raise "Missing hash!" unless value.instance_of?(Hash)
        value[:name] ||= key
        output[key] = new(value).data
      end
      output
    end

    def self.generate_to_csv(params)
      params.each do |key, value|
        raise "Missing hash!" unless value.instance_of?(Hash)
        value[:name] ||= key
        report = new(value)
        csv = report.generate_csv
        puts "Report generated to #{csv}"
      end
      true
    end

    def report_title
      return nil unless title.present?
      parsed_title = ValueParser.parse(title)
      parsed_title = parsed_title.join if parsed_title.instance_of?(Array)
      parsed_title
    end

    def generate_csv(path)
      write_to_csv(path, data)
    end

    def error_message
      errors.full_messages.to_s
    end

    private

    def write_to_csv(path, data)
      return path if File.exist?(path)
      CSV.open(path, "wb") do |csv|
        data.each { |row| csv << row }
      end
      path
    end
  end
end
