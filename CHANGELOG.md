# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.2] 2022-11-24
### Fixed
- Reference to schema file

## [0.3.1] 2022-11-24
### Fixed
- Add "json_schemer" to gem dependencies

## [0.3.0] 2022-11-24
### Added
- Add template object
- Report types can opt in to parsing the data themselves
- Added "to_csv" method to report
- Added ">string" array function
- Added ">range" array function
- Added ">sum" array function
- Added "!nf" and "!ni" to convert a number to a float or integer
- Added "snippets"
- Added JSON Schema for report validation

### Changed
- Preset report now takes in a "values" array, rather than a "data" array
- Refactor loader to be report loader
- "variables" have now been moved to be underneath the "metadata" tag.
- "metadata" is now passed to the Value parser instead of "variables"
- Re-ordered changelog to be latest change first
- Changelog now has KeepAChangelog info header

### Fixed
- The Method function now works with non-string targets

## [0.2.0] - 2022-10-14
### Added
- Added parser for true, false and nil ("@true", "@false", "@nil")
- Escape parsed methods and values starting with a special character
- Added Report parser
- Added "!j" join function.
- Added [">"] array helper functions.

### Changed
- Load from template method now parses the report through the Report parser.
- Plain strings in the model report method list return as a string rather than nil
- Arrays starting with a string containing only a hash attempt to use the second value as target
- Improved Loader's row splitting.
- Refactored Value parser, allowing for custom functions

### Fixed
- Method Parser no longer ignores empty and nil results.
- Model report no longer double-parses values.

## [0.1.1] - 2022-10-06
### Fixed
- Move Base class to it's own file
- Now uses require_rel rather than require_all

## [0.1.0] - 2022-10-06
- Initial release

### Added
- Value parser
- Method parser
- Preset report type
- Model report type
- Readme with report tutorial