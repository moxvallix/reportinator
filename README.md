# Reportinator
## Behold! My Report-inator!

**Warning: this gem can execute methods based on strings defined in a JSON file. Use at your own caution.**
**This gem has not been security audited, and should not be used in a production environment!**

Reportinator is a gem that allows you to easily define a report using a JSON file.
Report templates can reference other report templates, allowing for report "partials" to easily be re-used.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add reportinator

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install reportinator

## Usage

A Report template has four main keys:
- type: a symbol, specifying the report type
- variables: a hash of variables, for substitution
- template: a string, referencing the name of another template to load
- params: a hash of parameters that will be passed to the report

Reportinator also has it's own syntax for use in JSON templates:
- ":symbol": a string starting with a ":" will be converted to a symbol
- "&Constant": a string starting with a "&" will be constantized
- "$variable": a string starting with a "$" will substitute with a matching key in the variables hash
- "!functions":
    - "!a": addition, adds together comma seperated values ("!a 2,3" = 5)
    - "!i": converts following string to integer ("!i 100" = 100)
    - "!d": parses following string as a date ("!d 1970-01-01" = Jan 01, 1970)
    - "!r": converts comma seperated values to range ("!r !i 0, !i 100" = (0..100))

JSON templates can also be used to evaluate methods.
If the first element in an array is a string starting with a hash, it is parsed, and set as the target.
Subsequent elements in the array are chained as such:
- ["#100", ":to_i"] => "100".to_i = 100
- ["#100", ":reverse", ":to_i"] => "100".reverse.to_i = 1
Notice that methods are represented as symbols.

Parameters can be passed into a method by using a hash:
["#!d 1970-01-01", {"strftime": "%b, %Y"}] => (Jan 01, 1970).strftime("%b, %Y") = "Jan, 1970"
Keys in a hash are automatically converted to symbols.
Note: this only applies to the first value in a hash, all others are ignored.

### Example Report
For more examples, see app/reports.
```
{
    "type": ":preset",
    "params": {
        "data": [":symbol", "&Constant"]
    }
}
```

### Where to put my reports
By default, Reportinator checks `app/reports` for reports.

### Getting your Report's Output
`Reportinator.report(template, params)` will output a two dimensional array.
If you picture this as a table, each sub array is a row.

`Reportinator.output("report.csv", template, params)` will output the report to a csv,
at the specified path.

Template is the name of the template file, minus the ".json" suffix.
Here is how templates are resolved:
- "profit" => "app/reports/profit.json"
- "users/joined" => "app/reports/users/joined.json"

Params is a hash, accepting the same keys as a template would.
Params are merged with those provided by the template, overriding any conflicts.

### Configuring Reportinator
```
Reportinator.configuration do |config|
    config.report_directories = ["first/directory","other/directory"]
    config.report_suffixes = ["custom.json", "txt"]
    config.report_types = {
        my_type: "MyModule::MyReportType"
    }
end
```
Configuration set will not override the default configuration.
The keys used in report types, eg. `my_type`, will be the same used in the "type" field
of the reports.

### Making a Custom Report Type
The requirements to make a Report are very simple.
1. The report must inherit from `Reportinator::Report`
2. The report must provide a `data` method, which returns a one or two dimensional array.

For example, this is the entire code for the Preset Report:
```
module Reportinator
    class PresetReport < Report
        attribute :data, default: []
    end
end
```
Once a report has been written, it must be registed as a report type.
See the configuration section for more details.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/reportinator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/reportinator/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Reportinator project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/reportinator/blob/master/CODE_OF_CONDUCT.md).
