#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'ansi'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'tabularize'

table = Tabularize.new
table = Tabularize.new :pad     => '.', :pad_left => 2,  :pad_right => 0,
                       :border_style => :unicode,
                       :border_color => ANSI::Code.red,
                       :align   => [:left, :center, :right],
                       :valign  => [:top, :bottom, :middle, :middle],
                       :screen_width => 75, :ellipsis => '~'
table << %w[Name Dept Location Phone Description]
table.separator!
table << ['John Doe', 'Finance', 'Los Angeles CA 90089', '555-1555', 'Just a guy']
table << ['Average Joe', 'Engineering', 'Somewhere over the rainbow', 'N/A', 'Unknown']
table << ['홍길동', '탁상 3부', "서울역 3번 출구 김씨 옆자리\n\n맞습니다", 'N/A', 'No description']
puts table
