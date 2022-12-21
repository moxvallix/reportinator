module Reportinator
  class Template < Base
    attr_accessor :children
    attribute :type
    attribute :template
    attribute :params
    attribute :metadata

    def self.load(params = {})
      template = new(params)
      template.register
    end

    def register
      return load_template if template.present?
      self
    end

    def parse(meta = {}, data = {})
      output = []
      new_meta = metadata
      combine_meta = merge_hash(meta, new_meta)
      new_data = attributes.transform_keys { |key| key.to_sym }
      combine_data = merge_hash(new_data, data)
      if children.present? && children.respond_to?(:to_ary)
        children.each do |child|
          output += child.parse(combine_meta, combine_data) do |combine_data, meta, new_meta|
            yield(combine_data, meta, new_meta)
          end
        end
      else
        output << yield(combine_data, meta, new_meta)
      end
      output
    end

    private

    def load_template
      template_data = filter_template
      if template_data.respond_to? :to_ary
        data = template_data.map { |template| self.class.load(template) }
      else
        data = self.class.load(template_data)
      end
      self.children ||= []
      if data.respond_to? :to_ary
        self.children += data
      else
        self.children << data
      end
      self
    end

    def filter_template
      template_data = parse_template
      if template_data.respond_to? :to_ary
        template_data.map { |template| filter_params(template) }
      else
        filter_params(template_data)
      end
    end

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

    def validate_template(json)
      return true if Reportinator.schema.valid?(json)
      raise "Template doesn't match schema: #{Reportinator.schema.validate(json).to_a}"
    end

    def parse_template
      file = read_template
      begin
        plain_json = JSON.parse(file)
        symbolised_json = JSON.parse(file, symbolize_names: true)
      rescue
        raise "Error parsing template file: #{file}"
      end
      validate_template(plain_json)
      symbolised_json
    end

    def read_template
      file = find_template
      File.read(file)
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
