module Reportinator
  class MethodParser < Base
    attribute :target
    attribute :method

    def self.parse(target, method)
      new(target: target, method: method).output
    end

    def output
      return send_value(target, method) if method_class == Symbol
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
        next unless value.present?
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
      method = method.to_s
      return nil unless target_has_method?(target, method)
      return target.send(method) unless value.present?
      return target.send(method, *value) if value.instance_of?(Array)
      target.send(method, value)
    end

    def target_has_method?(target, method)
      target.methods.include?(method.to_sym)
    end

    def parse_method(target, method)
      self.class.parse(target, method)
    end
  end
end
