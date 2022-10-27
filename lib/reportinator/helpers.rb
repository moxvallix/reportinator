module Reportinator
  module Helpers

    def merge_hash(target, source)
      raise "Not a hash" unless target.instance_of?(Hash) && source.instance_of?(Hash)
      target.merge(source) do |key, old_value, new_value|
        if old_value.instance_of?(Hash) && new_value.instance_of?(Hash)
          merge_hash(old_value, new_value)
        elsif new_value.present?
          new_value
        else
          old_value
        end
      end
    end

  end
end