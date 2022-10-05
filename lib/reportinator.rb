# frozen_string_literal: true

require_relative "reportinator/version"

module Reportinator
  class Error < StandardError; end
  class << self
    attr_writer :config
    attr_writer :logger
  end

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield(config)
  end

  def self.logger
    @logger || ActiveSupport::Logger.new($stdout)
  end

  def self.report(template, additional_params = {})
    Loader.data_from_template(template, additional_params)
  end

  def self.output(path, template, additional_params = {})
    data = Loader.data_from_template(template, additional_params)
    CSV.open(path, "wb") do |csv|
      data.each do |row|
        csv << row
      end
    end
    path
  end

  class Base
    require "csv"
    require "json"
    require "active_support"
    require "active_model"
    require "require_all"

    include ActiveModel::API
    include ActiveModel::Attributes

    require_all "lib/reportinator"

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
