module Reportinator
  class Loader < Base
    attribute :type
    attribute :template
    attribute :variables
    attribute :params

    def self.data_from_template(template, additional_params = {})
      template_data = load_template(template, additional_params)
      return split_rows(template_data.data) unless template_data.instance_of?(Array)
      output = []
      template_data.each { |report| output += report.data }
      split_rows(output)
    end

    def self.load_template(template, additional_params = {})
      data = parse_template(template)
      return load_multiple(data, additional_params) if data.instance_of?(Array)
      load_singular(data, additional_params)
    end

    def self.load_multiple(data, additional_params)
      data.map { |report| load_singular(report, additional_params) }
    end

    def self.load_singular(data, additional_params)
      data.merge!(additional_params) { |key, old_value, new_value| merge_values(new_value, old_value) }
      filtered_data = filter_params(data, attribute_names)
      variables = filtered_data[:variables]
      parsed_data = ValueParser.parse(filtered_data, variables)
      new(parsed_data).report
    end

    def self.find_template(template)
      suffixes = config.configured_suffixes
      directories = config.configured_directories
      template_files = suffixes.map { |suffix| (suffix.present? ? "#{template}.#{suffix}" : template) }
      template_paths = directories.map { |dir| template_files.map { |file| "#{dir}/#{file}" } }
      template_paths.flatten!
      template_paths.each do |path|
        return path if File.exist? path
      end
      raise "Missing template: #{template}. Searched: #{template_paths}"
    end

    def self.parse_template(template)
      file = find_template(template)
      begin
        json = File.read(file)
        JSON.parse(json, symbolize_names: true)
      rescue
        raise "Error parsing template file: #{file}"
      end
    end

    def self.split_rows(data)
      data = data.instance_of?(Array) ? data : [data]
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

    def self.filter_params(params, allowed_params)
      filtered_params = params.select { |param| allowed_params.include? param.to_s }
      if params.size > filtered_params.size
        invalid_params = (params.keys - filtered_params.keys).map { |key| key.to_s }
        logger.warn "Invalid attributes found: #{invalid_params} Valid attributes are: #{allowed_params}"
      end
      filtered_params
    end

    def self.merge_values(new_value, old_value)
      return old_value.merge(new_value) if old_value.is_a?(Hash) && new_value.is_a?(Hash)
      new_value
    end

    def report
      if template.present?
        additional_params = {type: type, variables: variables, params: params}
        self.class.load_template(template, additional_params.compact)
      else
        attribute_list = report_class.attribute_names
        filtered_params = self.class.filter_params(params, attribute_list)
        report_class.new(filtered_params)
      end
    end

    def report_class
      types = config.configured_types
      raise "Invalid type: #{type}" unless types.include? type
      types[type].constantize
    end

    def template_file
      self.class.find_template(template)
    end

    def template_data
      self.class.parse_template(template)
    end
  end
end
