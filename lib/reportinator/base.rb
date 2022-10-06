module Reportinator
  class Base
    include ActiveModel::API
    include ActiveModel::Attributes

    require_rel "."

    def self.config
      Reportinator.config
    end

    def config
      self.class.config
    end

    def self.logger
      Reportinator.logger
    end

    def logger
      self.class.logger
    end
  end
end