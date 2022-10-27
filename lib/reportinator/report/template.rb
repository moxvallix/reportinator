module Reportinator
  class Template < Base
    attribute :type
    attribute :template
    attribute :params
    attribute :metadata

    def self.load(params = {})
      template = new(params)
      output = template.register
      return output.flatten if output.respond_to? :to_ary
      [output]
    end

    def register
      return load_template if template.present?
      self
    end
    
    def load_template
      template_data = merge_template
      if template_data.respond_to? :to_ary
        template_data.map { |template| self.class.load(template) }
      else
        self.class.load(template_data)
      end
    end

    def merge_template
      template_data = parse_template
      if template_data.respond_to? :to_ary
        template_data.map { |data| merge_with_attributes(data) }
      else
        merge_with_attributes(template_data)
      end
    end

    def merge_with_attributes(new_data)
      new_data = filter_params(new_data)
      current_data = attributes.transform_keys { |key| key.to_sym }
      current_data.delete(:template)
      merge_hash(new_data, current_data)
    end

    private

    def find_template
      raise "Template isn't a string" unless template.instance_of? String
      suffixes = config.configured_suffixes
      directories = config.configured_directories
      template_files = suffixes.map { |suffix| (suffix.present? ? "#{template}.#{suffix}" : template) }
      template_paths = directories.map { |dir| template_files.map { |file| "#{dir}/#{file}" } }
      template_paths.flatten!
      template_paths.each do |path|
        return path if File.exist? path
      end
      raise "Missing template: #{template}"
    end

    def parse_template
      file = find_template
      begin
        json = File.read(file)
        JSON.parse(json, symbolize_names: true)
      rescue
        raise "Error parsing template file: #{file}"
      end
    end

    def filter_params(params)
      filtered_params = params.select { |param| attribute_names.include? param.to_s }
      if params.size > filtered_params.size
        invalid_params = (params.keys - filtered_params.keys).map { |key| key.to_s }
        logger.warn "Invalid attributes found: #{invalid_params} Valid attributes are: #{attribute_names}"
      end
      filtered_params
    end
  end
end