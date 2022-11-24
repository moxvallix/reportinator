# frozen_string_literal: true

require "csv"
require "json"
require "fileutils"
require "active_support"
require "active_model"
require "require_all"
require "json_schemer"
require_relative "reportinator/version"
require_relative "reportinator/base"

module Reportinator
  SCHEMA = "#{__dir__}/../data/schema/report_schema.json"
  class Error < StandardError; end
  class << self
    attr_writer :config
    attr_writer :logger
    attr_writer :schema
  end

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield(config)
  end

  def self.schema
    return @schema if @schema.instance_of? JSONSchemer
    schema = JSON.parse(File.read(SCHEMA))
    @schema = JSONSchemer.schema(schema)
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
    report = ReportLoader.load(template, metadata).report
    data = report.to_csv
    if File.write(path, data)
      path
    else
      raise "Error writing to: #{path}"
    end
  end
end
