# Meer

A CLI utility for interacting with Datameer

## Installation

    gem install meer
    
Meer pulls the base url for what datameer to hit from environment variables, so be sure to set the location for your datameer.

    export DATAMEER_URL=https://my-datameer.example.com

## Usage

``` shell
$ meer help

Commands:
  meer csv             # outputs the CSV for a given workbook
  meer help [COMMAND]  # Describe available commands or one specific command
  meer login           # logs into datameer for quick access
  meer sheets          # lists all sheets in a workbook
  meer table           # outputs a nicely formatted table for a given workbook
  meer workbooks       # lists all workbooks
```

First thing you will want to do is login to datameer from the CLI. This will store your session id as a file in `~/.dmsession` so that you can interact with Datameer constantly typing credentials.

``` shell
$ meer login
username: (user.name)
password:
Logged In
```

Then you can start working with the data in Datameer like so

``` bash
$ meer workbook
 - [1] /foo.wbk
 - [2] /test.wbk
 
$ meer sheets 1
 - sheet_1
 - sheet_2
 - sheet_foo
 
$ meer csv 1 sheet_foo
"foo","bar","baz"
1,2,3
4,5,6
7,8,9


$ meer table 1 sheet_foo
+--------+--------+--------+
| foo    | bar    | baz    |
+--------+--------+--------+
| 1      | 2      | 3      |
+--------+--------+--------+
| 4      | 5      | 6      |
+--------+--------+--------+
| 7      | 8      | 9      |
+--------+--------+--------+
```


## Contributing

1. Fork it ( https://github.com/phil-monroe/meer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
