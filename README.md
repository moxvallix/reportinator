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
### Creating my first Report
Let's start by considering what we want our output to be.
Say we want a multiplication table, like such:
| nx1 | nx2 | nx3 | nx4 | nx5 |
|-----|-----|-----|-----|-----|
|  1  |  2  |  3  |  4  |  5  |
|  2  |  4  |  6  |  8  | 10  |
|  3  |  6  |  9  | 12  | 15  |
|  4  |  8  | 12  | 16  | 20  |
|  5  | 10  | 15  | 20  | 25  |

Make a new file in your `app/reports` directory.
Name it `multiplication.report.json`

Set it's type to ":preset". The ":preset" type takes one parameter, "data",
and returns any values passed inside it, but with their values parsed.
We put a colon in front of the word "preset", such that the value parser
knows to turn it into a symbol.

```
{
  "type": ":preset"
}
```

Next we need to give it parameters to be passed into the report.
":preset" only accepts the "data" parameter.
Add "data" to a "params" object, and set it to be an empty array.

```
{
  "type": ":preset",
  "params": {
    "data": []   
  }
}
```

You can now try running this report:

```
> Reportinator.report("multiplication")
=> []
```

If all went to plan, you should have gotten an empty array.
Let's now add some data to this bad boy.

```
{
  "type": ":preset",
  "params": {
    "data": ["nx1","nx2","nx3","nx4","nx5"]   
  }
}
```
```
> Reportinator.report("multiplication")
=> [["nx1", "nx2", "nx3", "nx4", "nx5"]]
```

Now we could add the other rows ourselves, by adding more rows to "data":

```
{
  "type": ":preset",
  "params": {
    "data": [
      ["nx1","nx2","nx3","nx4","nx5"],
      [1,2,3,4,5],
      [2,4,6,8,10],
      [3,6,9,12,15],
      [4,8,12,16,20],
      [5,10,15,20,25]
    ]   
  }
}
```
```
> Reportinator.report("multiplication")
=> 
[
  ["nx1", "nx2", "nx3", "nx4", "nx5"],
  [1, 2, 3, 4, 5],
  [2, 4, 6, 8, 10],
  [3, 6, 9, 12, 15],
  [4, 8, 12, 16, 20],
  [5, 10, 15, 20, 25]
]
```

However, there is a cleaner way of doing this.
Move your entire report object inside of an array.
This allows us to string reports together in the same template.

```
[
  {
    "type": ":preset",
    "params": {
      "data": ["nx1","nx2","nx3","nx4","nx5"]   
    }
  }
]
```

Add a new report object underneath the first.
This time, the type will be ":model".

":model" reports take two parameters:
  1. "target"
  2. "method_list"

Add both these keys to the "params" of the second report object.
Set both to be an empty array.

```
[
  {
    "type": ":preset",
    "params": {
      "data": ["nx1","nx2","nx3","nx4","nx5"]   
    }
  },
  {
    "type": ":model",
    "params": {
      "target": [],
      "method_list": []
    }
  }
]
```

Model reports take a target, as specified in "target", and run methods against it,
specified in "method_list", saving the outputs of each to the row.

If the target is enumerable, said methods will run on each enumeration of the target,
each enumeration adding a new row to the report.

A method is specified by either a symbol, array or hash.
Lets take the string "100" as our target.

If our method was to be `":reverse"`, it would be the same as running"

```
> "100".reverse
=> "001"
```

We can chain methods using an array. For example: `[":reverse", ":to_i"]`

```
> "100".reverse.to_i
=> 1
```

Methods inside a hash allow for parameters to be passed to the method.
The value of the hash are passed as the parameters, and an array is passed
as multiple parameters.

Eg. `{"gsub": ["0", "1"]}`

```
> "100".gsub("0", "1")
=> "111"
```

In Ruby, it turns out the multiplication "*" sign is a method.
Using this, we can write a much smarter report.

```
[
  {
    "type": ":preset",
    "params": {
      "data": ["nx1","nx2","nx3","nx4","nx5"]   
    }
  },
  {
    "type": ":model",
    "params": {
      "target": [1, 2, 3, 4, 5],
      "method_list": [{"*": 1},{"*": 2},{"*": 3},{"*": 4},{"*": 5}]
    }
  }
]
```

The "*" is behaving exactly the same way as our "gsub" example earlier.

If we run our report again:

```
> Reportinator.report("multiplication")
=> 
[
  ["nx1", "nx2", "nx3", "nx4", "nx5"],
  [1, 2, 3, 4, 5],
  [2, 4, 6, 8, 10],
  [3, 6, 9, 12, 15],
  [4, 8, 12, 16, 20],
  [5, 10, 15, 20, 25]
]
```

The result should be exactly the same.

This is pretty good, but we can do better!
Notice how the "target" was an array? As it is enumerable,
we could run our methods against each element within it.

But what if we wanted to have 10 rows? Or 50? Soon our array is going to get pretty long.

This is where a range would be perfect. Set the start value to 1, the end to whatever number we need,
and then we go from there.

Unfortunately, we can't use a range in JSON.

... or can we?

Reportinator has a bunch of handy built in functions, for converting strings.
We have already seen ":symbol" to make a string into a symbol.

We won't explore all the functions now, but we will explore "!r".
Or more specifically, "!rn", which auto converts strings into numbers as well.

We can make a range simply by writing "!rn 1,5". It takes the number before the comma,
as the start of the range, and the one after as the end.

We can test this with the actual parse method:

```
> Reportinator::ValueParser.parse("!rn 1, 5")
=> (1..5)
```

Let's add this now as the target of our report:

```
[
  {
    "type": ":preset",
    "params": {
      "data": ["nx1","nx2","nx3","nx4","nx5"]   
    }
  },
  {
    "type": ":model",
    "params": {
      "target": "!rn 1,5",
      "method_list": [{"*": 1},{"*": 2},{"*": 3},{"*": 4},{"*": 5}]
    }
  }
]
```

Finally, rather than peering at the console to see if it worked,
lets put it into a csv.

```
> Reportinator.output("multiplication.csv","multiplication")
=> "multiplication.csv"
```

Open the csv up in your spreadsheet viewer of choice, and revel
in your brand new report!
### Reports in more detail
#### The Report Template Object
A Report template has four attributes:

| key       | type   | description                                        |
|-----------|--------|----------------------------------------------------|
| type      | symbol | specifies the report type to use                   |
| variables | hash   | defines variables to be used with the `$` function |
| template  | string | references another template to load and merge with |
| params    | hash   | report specific parameters                         |

#### Reportinator String Parse Cheatsheet
| prefix | example                     | output                                     |
|--------|-----------------------------|--------------------------------------------|
| `:`    | ":symbol"                   | :symbol                                    |
| `&`    | "&Constant"                 | Constant                                   |
| `$`    | "$variable"                 | Value of key `variable` in variables hash. |
| `!a`   | "!a 1,2,3"                  | 6                                          |
| `!d`   | "!d 1970-01-01"             | 1970-01-01 00:00:00                        |
| `!n`   | "!n 100"                    | 100                                        |
| `!r`   | "!r a,z"                    | ("a".."z")                                 |
| `!rd`  | "!rd 1970-01-01,1979-01-01" | (1970-01-01 00:00:00..1979-01-01 00:00:00) |
| `!rn`  | "!rn 1,100"                 | (1..100)                                   |

#### Reportinator Method Parse Cheatsheet
When an array has a string as it's first value, and that string has the `#` prefix,
that string is parsed, and the result becomes the target of the following methods.

Hashes within the array take the first key in the hash as the method,
and the first value as parameters for that method. If the first value
is an array, each item in the array is sent as a seperate parameter.

Subsequent symbols in the array are sent as methods to the target.
| method array                                   | ruby equivalent               |
|------------------------------------------------|-------------------------------|
| `["#&Date", ":today"]`                         | Date.today                    |
| `["#&Date", ":today", ":to_s"]`                | Date.today.to_s               |
| `["#&Date", ":today", {"strftime": "%b, %Y"}]` | Date.today.strftime("%b, %Y") |
| `["#&Range", {"new": [1,100]}]`                | Range.new(1, 100)             |

### Where to put my Reports?
By default, Reportinator checks `app/reports` for reports.
It checks for files named `*.json` and `*.report.json`
More locations and suffixes can be added in the config.

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
