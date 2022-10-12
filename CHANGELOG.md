## [Unreleased]
### Added
- Added parser for true, false and nil ("@true", "@false", "@nil")
- Escape parsed methods and values starting with a special character
- Added Report parser
- Added "!j" join function, and "+" join array function
- Added ["+"] array joiner.

### Changed
- Load from template method now parses the report through the Report parser.
- Plain strings in the model report method list return as a string rather than nil
- Arrays starting with a string containing only a hash attempt to use the second value as target
- Improved Loader's row splitting.
- Refactored Value parser, allowing for custom functions

### Fixed
- Method Parser no longer ignores empty and nil results.

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