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
For a detailed walkthrough of creating your first report, see
[Creating my First Report](docs/0_first_report.md)

### Where to put my Reports?
By default, Reportinator checks `app/reports` for reports.
It checks for files named `*.json` and `*.report.json`
More locations and suffixes can be added in the config.

### Getting your Report's Output
`Reportinator.report(template, params)` will output a two dimensional array.
If you picture this as a table, each sub array is a row.
`params` is optional.

`Reportinator.output(template, params, filename)` will output the report to a csv,
in the configured output directory.
`params` and `filename` are optional.

Template is the name of the template file, minus the ".json" suffix.
Here is how templates are resolved:
- "profit" => "app/reports/profit.json"
- "users/joined" => "app/reports/users/joined.json"

Params is a hash, accepting the same keys as a template would.
Params are merged with those provided by the template, overriding any conflicts.

### Reports in more detail
#### The Report Template Object
A Report template has four attributes:

| key       | type   | description                                        |
|-----------|--------|----------------------------------------------------|
| type      | symbol | specifies the report type to use                   |
| variables | hash   | defines variables to be used with the `$` function |
| template  | string | references another template to load and merge with |
| params    | hash   | report specific parameters                         |

#### Reportinator String Function Cheatsheet
| prefix  | example                     | output                                     |
|---------|-----------------------------|--------------------------------------------|
| `:`     | ":symbol"                   | :symbol                                    |
| `&`     | "&Constant"                 | Constant                                   |
| `$`     | "$variable"                 | Value of key `variable` in variables hash. |
| `!a`    | "!a 1,2,3"                  | 6                                          |
| `!d`    | "!d 1970-01-01"             | 1970-01-01 00:00:00                        |
| `!n`    | "!n 100"                    | 100                                        |
| `!j`    | "!j 1,2,3"                  | "123"                                      |
| `!r`    | "!r a,z"                    | ("a".."z")                                 |
| `!rd`   | "!rd 1970-01-01,1979-01-01" | (1970-01-01 00:00:00..1979-01-01 00:00:00) |
| `!rn`   | "!rn 1,100"                 | (1..100)                                   |
| `@true` | "@true"                     | true                                       |
| `@false`| "@false"                    | false                                      |
| `@nil`  | "@nil"                      | nil                                        |
| `@null` | "@null"                     | nil                                        |

#### Reportinator Array Function Cheatsheet
When an array has a string as it's first value, and that string has a certain prefix
the array is parsed as an Array Function.

Array functions have a target, then an array of values. Often, the values will work
with the target to achieve an outcome.

Take for example this array:
```
["#&Date", ":today", ":to_s"]
```
This array has the following
- a prefix: `#`
- a target: `&Date` (Date)
- values: `[":today", ":to_s"]` ([:today, :to_s])

The `#` prefix tells the parser to run it as a Method Array.
The target, `&Date`, is parsed, then the values `[":today", ":to_s"]`
are parsed, and sent as methods to it. The result is returned.

This array is equivalent to running `Date.today.to_s`.

Optionally, the prefix can be put on it's own, with no additional values
after it.
```
["#", "&Date", ":today", ":to_s"]
```
This will still return the same result. Note that this allows the target
to be more flexible, as it no longer has to be resolved from a string.
```
["#", ["#&Date", ":today"], ":to_s"]
```
This array is equally valid, and still returns the same result.

 prefix    | example                                        | ruby equivalent                         |
-----------|------------------------------------------------|-----------------------------------------|
 `#`       | `["#&Date", ":today"]`                         | Date.today                              |
 `>join`   | `[">join", " - ", "a", "b", "c"]`              | ["a", "b", "c"].join(" - ")             |
 `>strf`   | `[">strf", ["#&Date", ":today"], "%b, %Y"]`    | Date.today.strftime("%b, %Y")           |
 `>offset` | `[">offset $time", 2, ":month", ":end"]`       | $time.advance(month: 2).at_end_of_month |
 `>title`  | `[">title", "hello", "world"]`                 | ["hello", "world"].join(" ").titleize   |

### Configuring Reportinator
```
Reportinator.configuration do |config|
    config.output_directory = "my/report/dir"
    config.report_directories = ["first/directory","other/directory"]
    config.report_suffixes = ["custom.json", "txt"]
    config.report_types = {
        my_type: "MyModule::MyReportType"
    }
    config.parser_functions = [
      "MyModule::MyParserFunction"
    ]
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

### Making a Custom Parser Function
The requirements to make a Parser Function are fairly simple:
1. The function must inherit from either "Reportinator::StringFunction"
or "Reportinator::ArrayFunction"
2. The function must have a PREFIXES constant, with an array of the prefixes it'll accept.
3. The function must provide an `output` method

String functions gain access to two variables:
- `prefix`, the prefix that the string used
- `body`, the rest of the string with the prefix removed

Array functions gain access to three variables:
- `prefix`, the prefix that was used
- `target`, the first value after the prefix
- `values`, the rest of the values, with the target removed

Once a function has been written, it must be registed as a parser function.
See the configuration section for more details.

#### Example String Function:
```
class TitleizeStringFunction < Reportinator::StringFunction
  PREFIXES = ["!t"]

  def output
    body.titleize
  end
end
```
```
> Reportinator.parse "!t hello world"
=> "Hello World"
```

#### Example Array Function:
```
class TargetSumArrayFunction < Reportinator::ArrayFunction
  PREFIXES = [">targetsum"]

  def output
    values.map { |value| value + target }
  end
end
```
```
> Reportinator.parse [">targetsum", 10, 1, 2, 3]
=> [11, 12, 13]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/moxvallix/reportinator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/moxvallix/reportinator/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Reportinator project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/moxvallix/reportinator/blob/master/CODE_OF_CONDUCT.md).
