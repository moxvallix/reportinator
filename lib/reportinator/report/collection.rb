module Reportinator
  class Collection < Array

    def includes_delimiter?
      self.each { |obj| return true if obj.instance_of?(Reportinator::Delimiter) }
      false
    end

    def delimit
      output = [[]]
      self.each do |obj|
        if obj.instance_of?(Reportinator::Delimiter)
          output << []
        else
          output.last << obj
        end
      end
      output
    end
  end
end
