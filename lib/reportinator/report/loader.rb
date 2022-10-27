module Reportinator
  class ReportLoader < Base
    attribute :template
    attribute :metadata

    def self.load(template, metadata = {})
      loader = new(metadata: metadata)
      loader.template = Template.load(template: template, metadata: metadata)
      loader
    end

    def get_metadata
      report_metadata = {}
      template.parse(metadata) do |data, old_meta, new_meta|
        meta = ValueParser.parse(new_meta, metadata)
        report_metadata = merge_hash(meta, report_metadata) if meta.present?
      end
      report_metadata
    end

    def report
      report = Report.new
      reports = template.parse(metadata) do |data, old_meta, new_meta|
        meta = ValueParser.parse(old_meta, metadata)
        parsed_meta = ValueParser.parse(new_meta, meta)
        report_meta = merge_hash(parsed_meta, meta)
        report_from_data(data, report_meta)
      end
      reports.compact.each do |report_template|
        output = report_template.data
        report.insert(output)
      end
      report
    end

    private

    def report_from_data(data, meta)
      report_type = report_class_from_data(data, meta)
      return nil unless report_type.present?
      return report_type.new(ValueParser.parse(data[:params], meta)) if report_type::PARSE_PARAMS
      report = report_type.new(data[:params])
      report.metadata = meta
      report
    end

    def report_class_from_data(data, meta)
      type = ValueParser.parse(data[:type], meta)
      return false unless type.present?
      report_class_from_type(type)
    end

    def report_class_from_type(type)
      types = config.configured_types
      raise "Invalid type: #{type}" unless types.include? type
      types[type].constantize
    end
  end
end
