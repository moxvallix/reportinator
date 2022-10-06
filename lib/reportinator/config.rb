module Reportinator
  class Config < Base
    DEFAULT_TYPES = {
      model: "Reportinator::ModelReport",
      preset: "Reportinator::PresetReport"
    }
    DEFAULT_REPORT_DIRS = ["reports", "app/reports"]
    DEFAULT_REPORT_SUFFIXES = ["report.json", "json"]

    attribute :report_directories, default: []
    attribute :report_suffixes, default: []
    attribute :report_types, default: {}
    attribute :output_directory, default: "reports"

    def configured_directories
      DEFAULT_REPORT_DIRS + report_directories
    end

    def configured_suffixes
      DEFAULT_REPORT_SUFFIXES + report_suffixes
    end

    def configured_types
      types = DEFAULT_TYPES
      types.merge(report_types)
    end
  end
end
