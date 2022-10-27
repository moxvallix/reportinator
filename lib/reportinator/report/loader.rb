module Reportinator
  class ReportLoader < Base
    attribute :templates
    attribute :metadata

    def self.load(template, metadata = {})
      loader = new(metadata: metadata)
      loader.templates = Template.load(template: template)
      loader
    end

    def get_metadata
      report_metadata = {}
      templates.each do |template|
        next unless template.metadata.instance_of? Hash
        report_metadata = merge_hash(report_metadata, template.metadata)
      end
      meta = merge_hash(report_metadata, metadata)
      ValueParser.parse(meta, metadata)
    end

    def report
      report = Report.new
      templates.each do |template|
        next unless template.type.present?
        data = report_from_template(template).data
        if data.respond_to? :to_ary
          data.each { |row| report.insert(row) }
        else
          report.insert(data)
        end
      end
      report
    end

    private

    def report_from_template(template)
      template_metadata = (template.metadata.present? ? template.metadata : {})
      template_metadata = ValueParser.parse(template_metadata, metadata)
      report_metadata = merge_hash(template_metadata, metadata)
      report_params = template.params
      input_data = ValueParser.parse(report_params, report_metadata)
      puts metadata
      puts template.metadata
      puts report_metadata
      puts input_data
      type = ValueParser.parse(template.type, report_metadata)
      report_class = report_class_from_type(type)
      if report_class::PARSE_PARAMS
        report_class.new(input_data)
      else
        report = report_class.new(template.params)
        report.metadata = report_metadata
        report
      end
    end

    def report_class_from_type(type)
      types = config.configured_types
      raise "Invalid type: #{type}" unless types.include? type
      types[type].constantize
    end
  end
end
