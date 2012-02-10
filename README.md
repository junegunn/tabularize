tabularize
==========

Formatting tabular data with paddings.
Inspired by tabular.vim (https://github.com/godlygeek/tabular)

Installation
------------

```
gem install tabularize
```

Basic usage
-----------

### Formatting CSV data

#### Sample data in CSV

```
Name|Dept|Location|Phone
John Doe|Finance|Los Angeles, CA 90089|555-1555
Average Joe|Engineering|Somewhere over the rainbow|N/A
Hong Gildong|HR|Nowhere|555-5555
```

#### Tabularize.it

```ruby
require 'csv'
require 'awesome_print'
require 'tabularize'

data = CSV.read 'test.csv', :col_sep => '|'
ap data
ap Tabularize.it(data).map { |row| row.join ' | ' }
```

# Output

```
[
    [0] [
        [0] "Name",
        [1] "Dept",
        [2] "Location",
        [3] "Phone"
    ],
    [1] [
        [0] "John Doe",
        [1] "Finance",
        [2] "Los Angeles, CA 90089",
        [3] "555-1555"
    ],
    [2] [
        [0] "Average Joe",
        [1] "Engineering",
        [2] "Somewhere over the rainbow",
        [3] "N/A"
    ],
    [3] [
        [0] "Hong Gildong",
        [1] "HR",
        [2] "Nowhere",
        [3] "555-5555"
    ]
]
[
    [0] "Name         | Dept        | Location                   | Phone   ",
    [1] "John Doe     | Finance     | Los Angeles, CA 90089      | 555-1555",
    [2] "Average Joe  | Engineering | Somewhere over the rainbow | N/A     ",
    [3] "Hong Gildong | HR          | Nowhere                    | 555-5555"
]
```

#### Alignment

```ruby

puts Tabularize.it(data, :align => :right).map { |row| row.join ' | ' }
puts
puts Tabularize.it(data, :align => :center).map { |row| row.join ' | ' }
```

```
        Name |        Dept |                   Location |    Phone
    John Doe |     Finance |      Los Angeles, CA 90089 | 555-1555
 Average Joe | Engineering | Somewhere over the rainbow |      N/A
Hong Gildong |          HR |                    Nowhere | 555-5555

    Name     |    Dept     |          Location          |  Phone  
  John Doe   |   Finance   |   Los Angeles, CA 90089    | 555-1555
Average Joe  | Engineering | Somewhere over the rainbow |   N/A   
Hong Gildong |     HR      |          Nowhere           | 555-5555
```

#### Padding with other characters
```ruby
puts Tabularize.it(data, :pad => '_').map { |row| row.join ' | ' }
```

```
Name________ | Dept_______ | Location__________________ | Phone___
John Doe____ | Finance____ | Los Angeles, CA 90089_____ | 555-1555
Average Joe_ | Engineering | Somewhere over the rainbow | N/A_____
Hong Gildong | HR_________ | Nowhere___________________ | 555-5555
```

Copyright
---------

Copyright (c) 2012 Junegunn Choi. See LICENSE.txt for
further details.

