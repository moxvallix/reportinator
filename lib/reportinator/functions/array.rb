module Reportinator
  class ArrayFunction < Function
    PREFIXES = []

    attribute :target
    attribute :values

    def self.accepts? input
      return false unless input.instance_of? Array
      return false if self::PREFIXES.empty?
      return false unless input[0].instance_of? String
      self::PREFIXES.each do |prefix|
        return true if input[0].start_with? prefix
      end
      false
    end

    def get
      raise "Function missing output!" unless respond_to? :output
      if set_attributes
        output
      else
        element
      end
    end
    
    def set_attributes
      array = element
      prefix = get_prefix(array[0])
      target_value = array.delete_at(0).sub(prefix, "")
      target_value = array.delete_at(0) if array.count > 1 && target_value.empty?
      if target_value.to_s.empty?
        false
      else
        self.target = target_value
        self.values = array
        true
      end
    end
  end
end
