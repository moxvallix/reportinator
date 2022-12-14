module Reportinator
  class MethodParser < Parser
    attribute :target
    attribute :method

    def self.parse(target, method)
      new(target: target, method: method).output
    rescue => e
      logger.error "[ERROR] #{e.class}: #{e}"
      logger.error "Parsing #{method} on #{target}"
      "Method Error"
    end

    def output
      if method_class == Symbol
        value = send_value(target, method)
        return escape_value(value)
      end
      return parse_array_method if method_class == Array
      return parse_hash_method if method_class == Hash
      nil
    end

    def method_class
      method.class
    end

    def parse_array_method
      raise "Not an array" unless method_class == Array
      valid = false
      output = target
      method.each do |m|
        value = parse_method(output, m)
        valid = true
        output = value
      end
      return output if valid
      nil
    end

    def parse_hash_method
      raise "Not a hash" unless method_class == Hash
      data = method.first
      method = data[0]
      value = data[1]
      send_value(target, method, value)
    end

    private

    def send_value(target, method, value = nil)
      return nil unless target_has_method?(target, method)
      method = method.to_s
      return target.send(method) unless value.present?
      return target.send(method, *value) if value.instance_of?(Array)
      target.send(method, value)
    end

    def target_has_method?(target, method)
      target.respond_to?(method)
    end

    def parse_method(target, method)
      self.class.parse(target, method)
    end
  end
end
