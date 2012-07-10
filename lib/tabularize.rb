require "tabularize/version"
require 'stringio'
require 'unicode/display_width'

class Tabularize
  DEFAULT_OPTIONS = {
    :align     => :left,
    :pad       => ' ',
    :pad_left  => 0,
    :pad_right => 0,

    :hborder   => '-',
    :vborder   => '|',
    :iborder   => '+',

    :unicode   => true,
    :ansi      => true,
  }

  DEFAULT_OPTIONS_GENERATOR = {
    :pad_left  => 1,
    :pad_right => 1,
  }

  def initialize options = {}
    @rows    = []
    @seps    = Hash.new { |h, k| h[k] = 0 }
    @options = DEFAULT_OPTIONS.
               merge(DEFAULT_OPTIONS_GENERATOR).
               merge(options)
  end

  def separator!
    @seps[@rows.length] += 1
    nil
  end
  
  # @param [Array] row
  def << row
    @rows << row
    nil
  end

  # @return [String]
  def to_s
    rows = Tabularize.it(@rows, @options)
    return nil if rows.empty?

    h = @options[:hborder]
    v = @options[:vborder]
    i = @options[:iborder]
    u = @options[:unicode]
    a = @options[:ansi]

    separator = i + rows[0].map { |c|
      h * Tabularize.cell_width(c, u, a)
    }.join( i ) + i

    output = StringIO.new
    output.puts separator
    rows.each_with_index do |row, idx|
      @seps[idx].times do
        output.puts separator
      end
      output.puts v + row.join(v) + v
    end
    output.puts separator
    output.string
  end

  # Returns the display width of a String
  # @param [String] str Input String
  # @param [Boolean] unicode Set to true when the given String can include CJK wide characters
  # @param [Boolean] ansi Set to true When the given String can include ANSI codes
  # @return [Fixnum] Display width of the given String
  def self.cell_width str, unicode, ansi
    str = str.gsub(/\e\[\d*(?:;\d+)*m/, '') if ansi
    str.send(unicode ? :display_width : :length)
  end

  # Formats two-dimensional tabular data.
  # One-dimensional data (e.g. Array of Strings) is treated as tabular data 
  # of which each row has only one column.
  # @param [Enumerable] table_data
  # @param [Hash] options Formatting options.
  # @return [Array] Two-dimensional Array of formatted cells.
  def self.it table_data, options = {}
    raise ArgumentError.new("Not enumerable") unless 
        table_data.respond_to?(:each)

    options = DEFAULT_OPTIONS.merge(options)
    pad     = options[:pad].to_s
    padl    = options[:pad_left]
    padr    = options[:pad_right]
    align   = [options[:align]].flatten
    unicode = options[:unicode]
    ansi    = options[:ansi]

    unless pad.length == 1
      raise ArgumentError.new("Invalid padding") 
    end
    unless padl.is_a?(Fixnum) && padl >= 0
      raise ArgumentError.new(":pad_left must be a non-negative Fixnum")
    end
    unless padr.is_a?(Fixnum) && padr >= 0
      raise ArgumentError.new(":pad_right must be a non-negative Fixnum")
    end
    unless align.all? { |a| [:left, :right, :center].include?(a) }
      raise ArgumentError.new("Invalid alignment")
    end

    rows       = []
    max_widths = []
    table_data.each do |row|
      rows << row = [*row].map(&:to_s).map(&:chomp)

      row.each_with_index do |cell, idx|
        max_widths[idx] = [ Tabularize.cell_width(cell, unicode, ansi), max_widths[idx] || 0 ].max
      end
    end

    rows.map { |row| 
      idx = -1
      row.map { |str|
        alen = 
          if ansi
            Tabularize.cell_width(str, false, false) -
              Tabularize.cell_width(str, false, true)
          else
            0
          end
        slen = str.length - alen

        idx += 1
        w = max_widths[idx]
        w += str.length - str.display_width if unicode
        pad * padl + 
          case align[idx] || align.last
          when :left
            str.ljust(w + alen, pad)
          when :right
            str.rjust(w + alen, pad)
          when :center
            str.rjust((w - slen) / 2 + slen + alen, pad).ljust(w + alen, pad)
          end +
            pad * padr
      }
    }
  end
end
