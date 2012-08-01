# encoding: utf-8
require 'rubygems'
require 'bundler'
Bundler.setup(:default, :development)
require 'test/unit'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'tabularize'
require 'awesome_print'
require 'csv'
require 'ansi'

class TestTabularize < Test::Unit::TestCase
  DATA0 = %w[a aa aaa aaaa aaaaa]
  DATA1 = 
    [
      %w[a aa aaa aaaa],
      %w[bbbb bbb bb b]
    ]
  DATA2 = 
    [
      %w[a aa aaa aaaa],
      %w[cccccccccccccccccccc],
      %w[ddd dddd d],
      %w[bbbb bbb bb b]
    ]
  RESULT = {
    DATA0 => {
      :left => [
        "a    ",
        "aa   ",
        "aaa  ",
        "aaaa ",
        "aaaaa",
      ],
      :right => [
        "    a",
        "   aa",
        "  aaa",
        " aaaa",
        "aaaaa",
      ],
      :center => [
        "  a  ",
        " aa  ",
        " aaa ",
        "aaaa ",
        "aaaaa",
      ],
    },
    DATA1 => {
      :left => 
        [
          "a   |aa |aaa|aaaa",
          "bbbb|bbb|bb |b   "
        ],
      :right => 
        [
          "   a| aa|aaa|aaaa",
          "bbbb|bbb| bb|   b"
        ],
      :center => 
        [
          " a  |aa |aaa|aaaa",
          "bbbb|bbb|bb | b  "
        ]
    },
    DATA2 => {
      :left =>
        [
          "a                   |aa  |aaa|aaaa",
          "cccccccccccccccccccc|    |   |    ",
          "ddd                 |dddd|d  |    ",
          "bbbb                |bbb |bb |b   "
        ],
      :right =>
        [
          "                   a|  aa|aaa|aaaa",
          "cccccccccccccccccccc|    |   |    ",
          "                 ddd|dddd|  d|    ",
          "                bbbb| bbb| bb|   b"
        ],
      :center =>
        [
          "         a          | aa |aaa|aaaa",
          "cccccccccccccccccccc|    |   |    ",
          "        ddd         |dddd| d |    ",
          "        bbbb        |bbb |bb | b  "
        ]
    }
  }

  def test_tabularize
    data_lines = DATA0.join($/).lines
    RESULT[data_lines] = RESULT[DATA0]
    [DATA0, data_lines, DATA1, DATA2].each do |data|
      [ '.', '_' ].each do |pad|
        [:left, :right, :center].each do |align|
          result = Tabularize.it(data, :pad => pad, :align => align)
          assert_equal RESULT[data][align], result.map { |row| row.join('|').gsub(pad, ' ') }
        end
      end
    end
  end

  def test_analyze
    data = []
    data << %w[a bb ccc]
    data << %w[aa bb cc]
    data << %w[aaa bb cc]
    data << %w[aaa bb cc] + ["dddd\neee"]
    data << %w[f]
    ret = Tabularize.analyze(data, :unicode => true, :ansi => true)
    assert_equal [%w[a bb ccc].push(''), %w[aa bb cc].push(''), %w[aaa bb cc].push(''),
                  %w[aaa bb cc] + ["dddd\neee"], %w[f] + [''] * 3], ret[:rows]
    assert_equal [1, 1, 1, 2, 1], ret[:max_heights]
    assert_equal [3, 2, 3, 4], ret[:max_widths]
  end

  # TODO: Need assertion
  def test_tabularize_csv
    return if RUBY_VERSION =~ /^1\.8\./

    sio = StringIO.new

    {
      'fixture/test.csv' => [false, false],
      'fixture/test_unicode.csv' => [true, false],
      'fixture/test_unicode_ansi.csv' => [true, true]
    }.each do |file, unicode_ansi|
      unicode, ansi = unicode_ansi
      opts = { :unicode => unicode, :ansi => ansi }
      data = CSV.read(File.join(File.dirname(__FILE__), file), :col_sep => '|')
      output = Tabularize.it(data, opts).map { |row| row.join '|' }

      sio.puts output
      sio.puts Tabularize.it(data, opts.merge(:align => :right)).map { |row| row.join '|' }
      sio.puts Tabularize.it(data, opts.merge(:align => :center)).map { |row| row.join '|' }
      sio.puts Tabularize.it(data, opts.merge(:pad => '_')).map { |row| row.join '|' }
    end

    assert_equal File.read(File.join(File.dirname(__FILE__), 'fixture/tabularize_csv.txt')), sio.string
  end

  def test_invalid_arguments
    assert_raise(ArgumentError) { Tabularize.it(5) }
    assert_raise(ArgumentError) { Tabularize.it("hello") } unless RUBY_VERSION =~ /^1\.8\./
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :align => :noidea) }
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :valign => :noidea) }
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :align => [:center, :top]) }
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :valign => [:left, :right]) }
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :pad => 'long') }
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :pad => ' ', :pad_left => -1) }
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :pad => ' ', :pad_left => '') }
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :pad => ' ', :pad_right => -1) }
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :pad => ' ', :pad_right => '') }
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :screen_width => -2) }
  end

  def test_table
    table = Tabularize.new :align => :center, :pad => ',',
      :pad_left => 3, :pad_right => 5, :hborder => '=', :vborder => 'I', :iborder => '#'
    table << DATA2[0]
    table.separator!
    table << DATA2[0]
    table.separator!
    table.separator!
    table << DATA2[1]
    table.separator!
    table << DATA2[2]
    table << DATA2[3]

    assert_equal(
'#============================#============#===========#============#
I,,,,,,,,,,,,a,,,,,,,,,,,,,,,I,,,,aa,,,,,,I,,,aaa,,,,,I,,,aaaa,,,,,I
#============================#============#===========#============#
I,,,,,,,,,,,,a,,,,,,,,,,,,,,,I,,,,aa,,,,,,I,,,aaa,,,,,I,,,aaaa,,,,,I
#============================#============#===========#============#
#============================#============#===========#============#
I,,,cccccccccccccccccccc,,,,,I,,,,,,,,,,,,I,,,,,,,,,,,I,,,,,,,,,,,,I
#============================#============#===========#============#
I,,,,,,,,,,,ddd,,,,,,,,,,,,,,I,,,dddd,,,,,I,,,,d,,,,,,I,,,,,,,,,,,,I
I,,,,,,,,,,,bbbb,,,,,,,,,,,,,I,,,bbb,,,,,,I,,,bb,,,,,,I,,,,b,,,,,,,I
#============================#============#===========#============#', table.to_s)
  end

  def test_table_complex
    separator = '#~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#'
    output = "
#~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
I..Name.......I.....Dept....I.....................LocationI.....PhoneI
#~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
I..John Doe...I....Finance..I.........Los Angeles CA 90089I..555-1555I
I..Average JoeI..EngineeringI...Somewhere over the rainbowI.......N/AI
I..1..........I.............I.............................I..........I
#~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
#~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
I..홍길동.....I.............I..서울역 3번 출구 김씨 옆자리I..........I
I.............I.............I.............................I.......N/AI
I.............I...탁상 3부..I.....................맞습니다I..........I
#~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
#~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
#~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
    ".strip

    table = Tabularize.new :pad     => '.', :pad_left => 2,  :pad_right => 0,
                           :hborder => '~', :vborder => 'I', :iborder => '#',
                           :align   => [:left, :center, :right],
                           :valign  => [:top, :bottom, :middle, :middle]
    table << %w[Name Dept Location Phone]
    table.separator!
    table << ['John Doe', 'Finance', 'Los Angeles CA 90089', '555-1555']
    table << ['Average Joe', 'Engineering', 'Somewhere over the rainbow', 'N/A']
    table << [1]
    table.separator!
    table.separator!
    table << ['홍길동', '탁상 3부', "서울역 3번 출구 김씨 옆자리\n\n맞습니다", 'N/A']
    table.separator!
    table.separator!

    100.times do
      assert_equal output, table.to_s.strip
    end
    table.separator!
    table.separator!
    assert_equal [output, separator, separator].join($/), table.to_s.strip
    assert_equal [output, separator, separator].join($/), table.to_s.strip
    table << "This should change everything doh!"
    output = "
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
I..Name..............................I.....Dept....I.....................LocationI.....PhoneI
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
I..John Doe..........................I....Finance..I.........Los Angeles CA 90089I..555-1555I
I..Average Joe.......................I..EngineeringI...Somewhere over the rainbowI.......N/AI
I..1.................................I.............I.............................I..........I
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
I..홍길동............................I.............I..서울역 3번 출구 김씨 옆자리I..........I
I....................................I.............I.............................I.......N/AI
I....................................I...탁상 3부..I.....................맞습니다I..........I
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
I..This should change everything doh!I.............I.............................I..........I
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#".strip
    assert_equal output, table.to_s.strip
    assert_equal output, table.to_s.strip

    separator = '#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#'
    line = 'I..a.................................I.......b.....I............................cI.........dI'
    10.times do |i|
      table << %w[a b c d]
      expected = (output.lines.to_a[0..-2].map(&:chomp) + [line] * (i+1) + [separator]).join($/)
      assert_equal expected, table.to_s
    end
  end

  def test_screen_width
    [1, 3, 9, 50, 80].each do |w|
      t = Tabularize.new :screen_width => w
      10.times do
        t << ['12345'] * 20
      end
      assert t.to_s.lines.all? { |line| (w-9..w).include? line.chomp.length }
      t << %w[12345]
      puts t.to_s
      assert t.to_s.lines.all? { |line| (w-9..w).include? line.chomp.length }
      assert t.to_s.lines.all? { |line| line.chomp.reverse[0, 1] == '>' }
    end
  end

  def test_readme
    table = Tabularize.new :pad     => '.', :pad_left => 2,  :pad_right => 0,
                           :border_style => :unicode,
                           :align   => [:left, :center, :right],
                           :valign  => [:top, :bottom, :middle, :middle],
                           :screen_width => 75, :ellipsis => '~'
    table << %w[Name Dept Location Phone Description]
    table.separator!
    table << ['John Doe', 'Finance', 'Los Angeles CA 90089', '555-1555', 'Just a guy']
    table << ['Average Joe', 'Engineering', 'Somewhere over the rainbow', 'N/A', 'Unknown']
    table << ['홍길동', '탁상 3부', "서울역 3번 출구 김씨 옆자리\n\n맞습니다", 'N/A', 'No description']
    assert_equal "
┌─────────────┬─────────────┬─────────────────────────────┬──────────~
│..Name.......│.....Dept....│.....................Location│.....Phone~
├─────────────┼─────────────┼─────────────────────────────┼──────────~
│..John Doe...│....Finance..│.........Los Angeles CA 90089│..555-1555~
│..Average Joe│..Engineering│...Somewhere over the rainbow│.......N/A~
│..홍길동.....│.............│..서울역 3번 출구 김씨 옆자리│..........~
│.............│.............│.............................│.......N/A~
│.............│...탁상 3부..│.....................맞습니다│..........~
└─────────────┴─────────────┴─────────────────────────────┴──────────~
".strip, table.to_s
  end

  def test_unicode_border_with_screen_width
    table = Tabularize.new :border_style => :unicode, :unicode => false, :screen_width => 200
    table << %w[abcde] * 100
    assert table.to_s.lines.first.display_width > 190
  end
end
