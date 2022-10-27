# frozen_string_literal: true

require "csv"
require "json"
require "fileutils"
require "active_support"
require "active_model"
require "require_all"
require_relative "reportinator/version"
require_relative "reportinator/base"

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

  def self.parse(input, metadata = {})
    ValueParser.parse(input, metadata)
  end

  def self.report(template, metadata = {})
    report = ReportLoader.load(template, metadata).report
    report.output
  end

  def self.output(template, metadata = {}, filename = "")
    filename = (filename.present? ? filename : "#{template}.csv")
    path = "#{config.output_directory}/#{filename}"
    FileUtils.mkdir_p(File.dirname(path))
    data = report(template, metadata)
    CSV.open(path, "wb") do |csv|
      data.each do |row|
        csv << row
      end
    end
    path
  end
end
