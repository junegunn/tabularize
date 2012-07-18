tabularize
==========

Formatting tabular data with paddings.
[tabularize](https://github.com/junegunn/tabularize) correctly handles
CJK (Chinese, Japanese and Korean) wide characters and ANSI codes.

Inspired by tabular.vim (https://github.com/godlygeek/tabular)

Installation
------------

```
gem install tabularize
```

Table generator
---------------

```ruby
require 'tabularize'

table = Tabularize.new
table << %w[Name Dept Location Phone]
table.separator!
table << ['John Doe', 'Finance', 'Los Angeles CA 90089', '555-1555']
table << ['Average Joe', 'Engineering', 'Somewhere over the rainbow', 'N/A']
table << ['홍길동', '탁상 3부', '서울역 3번 출구 김씨 옆자리', 'N/A']
puts table
```

```
+-------------+-------------+-----------------------------+----------+
| Name        | Dept        | Location                    | Phone    |
+-------------+-------------+-----------------------------+----------+
| John Doe    | Finance     | Los Angeles CA 90089        | 555-1555 |
| Average Joe | Engineering | Somewhere over the rainbow  | N/A      |
| 홍길동      | 탁상 3부    | 서울역 3번 출구 김씨 옆자리 | N/A      |
+-------------+-------------+-----------------------------+----------+
```

### With options: Padding, border and alignment

* Padding
 * `:pad` Padding character
 * `:pad_left` Size of left padding
 * `:pad_right` Size of right padding
* Border
 * `:hborder` Character for horizontal border
 * `:vborder` Character for vertical border
 * `:iborder` Character for intersection point
* Alignment
 * `:align` Horizontal alignment. `:left`, `:center`, `:right`, or Array of the three options
 * `:valign` Vertical alignment. `:top`, `:middle`, `:bottom`, or Array of the three options

```ruby
table = Tabularize.new :pad     => '.', :pad_left => 2,  :pad_right => 0,
                       :hborder => '~', :vborder => 'I', :iborder => '#',
                       :align   => [:left, :center, :right],
                       :valign  => [:top, :bottom, :middle, :middle]
table << %w[Name Dept Location Phone]
table.separator!
table << ['John Doe', 'Finance', 'Los Angeles CA 90089', "555-1555"]
table << ['Average Joe', 'Engineering', 'Somewhere over the rainbow', 'N/A']
table << ['홍길동', '탁상 3부', "서울역 3번 출구 김씨 옆자리\n\n맞습니다", 'N/A']
puts table
```

```
#~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
I..Name.......I.....Dept....I.....................LocationI.....PhoneI
#~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
I..John Doe...I....Finance..I.........Los Angeles CA 90089I..555-1555I
I..Average JoeI..EngineeringI...Somewhere over the rainbowI.......N/AI
I..홍길동.....I.............I..서울역 3번 출구 김씨 옆자리I..........I
I.............I.............I.............................I.......N/AI
I.............I...탁상 3부..I.....................맞습니다I..........I
#~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
```

Tabularize.it
-------------
`Tabularize` table generator is built on top of low-level `Tabularize.it` class method.
(actually it was the only method provided in the earlier versions prior to 0.2.0)

It simply returns two-dimensional array of padded and aligned Strings,
so the rest of the formatting is pretty much up to you.

### Example: formatting CSV data

#### Sample data in CSV

```
Name|Dept|Location|Phone
John Doe|Finance|Los Angeles, CA 90089|555-1555
Average Joe|Engineering|Somewhere over the rainbow|N/A
Hong Gildong|HR|Nowhere|555-5555
홍길동|탁상 3부|서울역 3번 출구 김씨 옆자리|N/A
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

#### Output

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

#### Alignments

```ruby
puts Tabularize.it(data, :align => :right).map { |row| row.join ' | ' }
puts
puts Tabularize.it(data, :align => [:left, :center]).map { |row| row.join ' | ' }
```

```
        Name |        Dept |                   Location |    Phone
    John Doe |     Finance |      Los Angeles, CA 90089 | 555-1555
 Average Joe | Engineering | Somewhere over the rainbow |      N/A
Hong Gildong |          HR |                    Nowhere | 555-5555

Name         |    Dept     |          Location          |  Phone  
John Doe     |   Finance   |   Los Angeles, CA 90089    | 555-1555
Average Joe  | Engineering | Somewhere over the rainbow |   N/A   
Hong Gildong |     HR      |          Nowhere           | 555-5555
```

#### Padding with characters other than space

```ruby
puts Tabularize.it(data, :pad => '_').map { |row| row.join ' | ' }
```

```
Name________ | Dept_______ | Location__________________ | Phone___
John Doe____ | Finance____ | Los Angeles, CA 90089_____ | 555-1555
Average Joe_ | Engineering | Somewhere over the rainbow | N/A_____
Hong Gildong | HR_________ | Nowhere___________________ | 555-5555
홍길동______ | 탁상 3부___ | 서울역 3번 출구 김씨 옆자리 | N/A_____
```

ANSI codes and CJK wide characters
----------------------------------
[tabularize](https://github.com/junegunn/tabularize) correctly calculates each cell width even in the presence of ANSI codes and CJK wide characters.
However, if your data doesn't have any of them, unset `:unicode` and `:ansi` in options hash,
so that [tabularize](https://github.com/junegunn/tabularize) can process data more efficiently.

```ruby
table = Tabularize.new :unicode => false, :ansi => false
```

Related work
------------
I wasn't aware of [terminal-table](https://github.com/visionmedia/terminal-table)
when I blindly started building [tabularize](https://github.com/junegunn/tabularize).
It has more features and clearly is more mature than [tabularize](https://github.com/junegunn/tabularize),
you should definitely check it out.

There are a couple of things, however, [tabularize](https://github.com/junegunn/tabularize) does better:
- It correctly formats cells containing CJK wide characters.
- Vertical alignment for multi-line cells

Copyright
---------

Copyright (c) 2012 Junegunn Choi. See LICENSE.txt for
further details.

