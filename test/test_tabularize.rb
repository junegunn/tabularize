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
          "cccccccccccccccccccc",
          "ddd                 |dddd|d  ",
          "bbbb                |bbb |bb |b   "
        ],
      :right =>
        [
          "                   a|  aa|aaa|aaaa",
          "cccccccccccccccccccc",
          "                 ddd|dddd|  d",
          "                bbbb| bbb| bb|   b"
        ],
      :center =>
        [
          "         a          | aa |aaa|aaaa",
          "cccccccccccccccccccc",
          "        ddd         |dddd| d ",
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
          ap :align => align, :pad => pad, :from => data, :to => result.map { |r| r.join('|') }
          assert_equal RESULT[data][align], result.map { |row| row.join('|').gsub(pad, ' ') }
        end
      end
    end
  end

  # TODO: Need assertion
  def test_tabularize_csv
    {
      'test.csv' => [false, false],
      'test_unicode.csv' => [true, false],
      'test_unicode_ansi.csv' => [true, true]
    }.each do |file, unicode_ansi|
      unicode, ansi = unicode_ansi
      opts = { :unicode => unicode, :ansi => ansi }
      data = CSV.read(File.join(File.dirname(__FILE__), file), :col_sep => '|')
      ap data
      output = Tabularize.it(data, opts).map { |row| row.join '|' }
      ap output
      puts
      puts output

      puts Tabularize.it(data, opts.merge(:align => :right)).map { |row| row.join '|' }
      puts
      puts Tabularize.it(data, opts.merge(:align => :center)).map { |row| row.join '|' }
      puts
      puts Tabularize.it(data, opts.merge(:pad => '_')).map { |row| row.join '|' }

    end
  end

  def test_invalid_arguments
    assert_raise(ArgumentError) { Tabularize.it(5) }
    assert_raise(ArgumentError) { Tabularize.it("hello") }
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :align => :noidea) }
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :valign => :noidea) }
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :align => [:center, :top]) }
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :valign => [:left, :right]) }
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :pad => 'long') }
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :pad => ' ', :pad_left => -1) }
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :pad => ' ', :pad_left => '') }
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :pad => ' ', :pad_right => -1) }
    assert_raise(ArgumentError) { Tabularize.it([1, 2, 3], :pad => ' ', :pad_right => '') }
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

    puts table.to_s
  end

  def test_table_complex
    output = "
#~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
I..Name.......I.....Dept....I.....................LocationI.....PhoneI
#~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
I..John Doe...I....Finance..I.........Los Angeles CA 90089I..555-1555I
I..Average JoeI..EngineeringI...Somewhere over the rainbowI.......N/AI
I..1..........I
#~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
#~~~~~~~~~~~~~#~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~~~#
I..홍길동.....I.............I..서울역 3번 출구 김씨 옆자리I..........I
I.............I.............I.............................I.......N/AI
I.............I...탁상 3부..I.....................맞습니다I..........I
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
    assert_equal output, table.to_s.strip
  end
end
