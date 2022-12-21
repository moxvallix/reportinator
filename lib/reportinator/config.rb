module Reportinator
  class Config < Base
    DEFAULT_TYPES = {
      model: "Reportinator::ModelReport",
      preset: "Reportinator::PresetReport"
    }
    DEFAULT_REPORT_DIRS = ["reports", "app/reports"]
    DEFAULT_REPORT_SUFFIXES = ["report.json", "json"]
    DEFAULT_FUNCTIONS = [
      "Reportinator::HelperArrayFunction",
      "Reportinator::JoinArrayFunction",
      "Reportinator::RangeArrayFunction",
      "Reportinator::StringArrayFunction",
      "Reportinator::SnippetArrayFunction",
      "Reportinator::FlattenArrayFunction",
      "Reportinator::MethodArrayFunction",
      "Reportinator::RepeatArrayFunction",
      "Reportinator::AdditionStringFunction",
      "Reportinator::ConstantStringFunction",
      "Reportinator::DateStringFunction",
      "Reportinator::JoinStringFunction",
      "Reportinator::LogicalStringFunction",
      "Reportinator::NumberStringFunction",
      "Reportinator::RangeStringFunction",
      "Reportinator::SymbolStringFunction",
      "Reportinator::VariableStringFunction"
    ]
    DEFAULT_UNPARSEDS = [:snippets]

    attribute :report_directories, default: []
    attribute :report_suffixes, default: []
    attribute :report_types, default: {}
    attribute :parser_functions, default: []
    attribute :unparsed_metadata, default: []
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

    def configured_functions
      functions = DEFAULT_FUNCTIONS + parser_functions
      functions.map { |function| function.constantize }
    end

    def configured_metadata
      DEFAULT_UNPARSEDS + unparsed_metadata
    end
  end
end
