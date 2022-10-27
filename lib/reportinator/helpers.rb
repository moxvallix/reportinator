module Reportinator
  module Helpers

    def merge_hash(target, source)
      target = target.present? ? target : {}
      source = source.present? ? source : {}
      merge_hash!(target, source)
    end

    def merge_hash!(target, source)
      raise "Target: #{target} is not a hash" unless target.instance_of?(Hash)
      raise "Source: #{source} is not a hash" unless source.instance_of?(Hash)
      target.merge(source) do |key, old_value, new_value|
        if old_value.instance_of?(Hash) && new_value.instance_of?(Hash)
          merge_hash!(old_value, new_value)
        elsif new_value.present?
          new_value
        else
          old_value
        end
      end
    end

    def symbolize_attributes(target)
      raise "Missing attributes" unless target.respond_to? :attributes
      raise "Invalid attributes" unless target.attributes.instance_of? Hash
      target.attributes.transform_keys { |key| key.to_sym }
    end

  end
end