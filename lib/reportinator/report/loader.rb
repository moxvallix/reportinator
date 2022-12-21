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
        meta = parse_metadata(data, old_meta, new_meta)
        report_metadata = merge_hash(meta, report_metadata) if meta.present?
      end
      report_metadata
    end

    def report
      report = Report.new
      reports = template.parse(metadata) do |data, old_meta, new_meta|
        parsed_meta = parse_metadata(data, old_meta, new_meta)
        report_from_data(data, parsed_meta)
      end
      reports.compact.each do |report_template|
        output = report_template.data
        report.insert(output)
      end
      report
    end

    def parse_metadata(data, old_meta, new_meta)
      meta = ValueParser.parse(old_meta, metadata)
      if new_meta.instance_of? Hash
        unparsed_meta = new_meta.select { |key| config.configured_metadata.include? key }
        meta_to_parse = new_meta.reject { |key| config.configured_metadata.include? key }
        parsing_meta = merge_hash(meta, unparsed_meta)
        parsed_meta = ValueParser.parse(meta_to_parse, parsing_meta)
        remerged_meta = merge_hash(parsed_meta, unparsed_meta)
      else
        remerged_meta = {}
      end
      merge_hash(remerged_meta, meta)
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
