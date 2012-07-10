#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'ansi'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'tabularize'

table = Tabularize.new
table = Tabularize.new :pad => '.', :pad_left => 2, :pad_right => 0,
                       :hborder => '~', :vborder => 'I', :iborder => '#',
                       :align => [:left, :center, :right]
table << %w[Name Dept Location Phone]
table.separator!
table << ['John Doe', 'Finance', 'Los Angeles CA 90089', '555-1555']
table << ['Average Joe', 'Engineering', 'Somewhere over the rainbow', 'N/A']
table << ['홍길동', '탁상 3부', '서울역 3번 출구 김씨 옆자리', 'N/A']
puts table
