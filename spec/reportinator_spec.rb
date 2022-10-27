# frozen_string_literal: true

TYPES = [
  {input: ":symbol", output: :symbol, type: "symbol"},
  {input: "&Reportinator", output: Reportinator, type: "constant"},
  {input: "!n 100", output: 100, type: "integer number"},
  {input: "!n 100.0", output: 100.0, type: "float number"},
  {input: "!a 50, 50", output: 100, type: "addition"},
  {input: "!d 1970-01-01", output: Time.parse("1970-01-01"), type: "date"},
  {input: "!rn 1, 100", output: (1..100), type: "number range"},
  {input: "!r a, z", output: ("a".."z"), type: "string range"},
  {
    input: "!rd 1970-01-01, 1980-01-01",
    output: (Time.parse("1970-01-01")..Time.parse("1980-01-01")),
    type: "date range"
  },
  {input: "@true", output: true, type: "logical true"},
  {input: "@false", output: false, type: "logical false"},
  {input: "@nil", output: nil, type: "logical nil"},
  {input: "@null", output: nil, type: "logical nil (null input)"},
  {input: "$test", output: "test output", type: "variable", variables: {variables: {test: "test output"}}},
  {input: ["#&Date", ":today"], output: Date.today, type: "method"},
  {input: ["#", "&Date", ":today"], output: Date.today, type: "method (prefix separate)"},
  {input: [">join ", "a", "b", "c"], output: "a b c", type: "helper (join)"},
  {input: [">strf !d 1970-01-01", "%b, %Y"], output: "Jan, 1970", type: "helper (strf)"},
  {input: [">offset !d 1970-01-01", 1, ":year", ":start"], output: Time.parse("1971-01-01"), type: "helper (offset)"},
  {input: [">title", "hello", "world"], output: "Hello World", type: "helper (title)"}
]

REPORTS = [
  {template: "standard/test_001", output: [["string", :symbol]]},
  {template: "standard/test_002", output: [["Jan, 1970"]]},
  {template: "standard/test_003", output: [["a", "b", "c"], ["1", "2", "3"]]},
  {template: "standard/test_004", output: [["a", "b", "c"], ["1", "2", "3"]]}
]

INVALID_REPORTS = [
  {template: "invalid/test_missing", error: "Missing template"},
  {template: "invalid/test_001", error: "Invalid type: missing"},
  {template: "invalid/test_002", error: "Missing template"},
  {template: "invalid/test_004", error: "Error parsing template file"}
]

def parses_type_test(type, input, output, variables)
  it "parses a type of: #{type}" do
    parsed = Reportinator::ValueParser.parse(input, variables)
    expect(parsed).to eql(output)
  end
end

def generates_report_test(template, output)
  it "generates report: #{template}" do
    report = Reportinator.report(template)
    expect(report).to eq(output)
  end
end

def invalid_report_test(template, error)
  it "raises error on: #{template}" do
    expect { Reportinator.report(template) }.to raise_error(/#{error}/)
  end
end

RSpec.describe Reportinator do
  it "has a version number" do
    expect(Reportinator::VERSION).not_to be nil
  end

  context "can set config" do
    Reportinator.configure do |config|
      config.report_directories = ["spec/reports"]
      config.report_suffixes = ["test.json"]
    end
    it "configures report directories" do
      check = Reportinator.config.configured_directories.include? "spec/reports"
      expect(check).to be true
    end
    it "configures report suffixes" do
      check = Reportinator.config.configured_suffixes.include? "test.json"
      expect(check).to be true
    end
  end

  context "can parse types" do
    TYPES.each do |type|
      parses_type_test(type[:type], type[:input], type[:output], type[:variables])
    end
  end

  context "can generate reports" do
    REPORTS.each do |report|
      generates_report_test(report[:template], report[:output])
    end
  end

  context "will fail on invalid reports" do
    INVALID_REPORTS.each do |report|
      invalid_report_test(report[:template], report[:error])
    end
  end
end
