module Reportinator
  class StringFunction < Function
    PREFIXES = []

    attribute :prefix
    attribute :body

    def self.accepts? input
      return false unless input.instance_of? String
      return false if self::PREFIXES.empty?
      self::PREFIXES.each do |prefix|
        return true if input.start_with? prefix
      end
      false
    end

    def get
      raise "Function missing output!" unless respond_to? :output
      set_attributes
      output
    end

    def set_attributes
      prefix = get_prefix(element)
      self.prefix = prefix
      self.body = element.sub(prefix, "")
    end
  end
end
