## [Unreleased]
### Added
- Added parser for true, false and nil ("@true", "@false", "@nil")
- Escape parsed methods and values starting with a special character
- Added Report parser

### Changed
- Load from template method now parses the report through the Report parser.
- Plain strings in the model report method list return as a string rather than nil

## [0.1.0] - 2022-10-06
- Initial release

### Added
- Value parser
- Method parser
- Preset report type
- Model report type
- Readme with report tutorial

## [0.1.1] - 2022-10-06
### Fixed
- Move Base class to it's own file
- Now uses require_rel rather than require_all