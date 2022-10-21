# Creating my First Report
Let's start by considering what we want our output to be.
Say we want a multiplication table, like such:
| nx1 | nx2 | nx3 | nx4 | nx5 |
|-----|-----|-----|-----|-----|
|   1 |   2 |   3 |   4 |   5 |
|   2 |   4 |   6 |   8 |  10 |
|   3 |   6 |   9 |  12 |  15 |
|   4 |   8 |  12 |  16 |  20 |
|   5 |  10 |  15 |  20 |  25 |

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
    "values": []   
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
    "values": ["nx1","nx2","nx3","nx4","nx5"]
  }
}
```
```
> Reportinator.report("multiplication")
=> [["nx1", "nx2", "nx3", "nx4", "nx5"]]
```

Now we could add the other rows ourselves, by adding more rows to "values":

```
{
  "type": ":preset",
  "params": {
    "values": [
      ["nx1","nx2","nx3","nx4","nx5"],
      [1, 2, 3, 4, 5],
      [2, 4, 6, 8, 10],
      [3, 6, 9, 12, 15],
      [4, 8, 12, 16, 20],
      [5, 10, 15, 20, 25]
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
      "values": ["nx1","nx2","nx3","nx4","nx5"]   
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
      "values": ["nx1","nx2","nx3","nx4","nx5"]   
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
      "values": ["nx1","nx2","nx3","nx4","nx5"]   
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
> Reportinator.parse("!rn 1, 5")
=> (1..5)
```

Let's add this now as the target of our report:

```
[
  {
    "type": ":preset",
    "params": {
      "values": ["nx1","nx2","nx3","nx4","nx5"]
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