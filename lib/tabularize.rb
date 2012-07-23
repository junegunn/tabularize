require "tabularize/version"
require 'stringio'
require 'unicode/display_width'

class Tabularize
  DEFAULT_OPTIONS = {
    :align     => :left,
    :valign    => :top,
    :pad       => ' ',
    :pad_left  => 0,
    :pad_right => 0,

    :hborder   => '-',
    :vborder   => '|',
    :iborder   => '+',

    :unicode   => true,
    :ansi      => true,

    :ellipsis     => '>',
    :screen_width => nil,
  }

  DEFAULT_OPTIONS_GENERATOR = {
    :pad_left  => 1,
    :pad_right => 1,
  }

  # @since 0.2.0
  def initialize options = {}
    @rows    = []
    @seps    = Hash.new { |h, k| h[k] = 0 }
    @options = DEFAULT_OPTIONS.
               merge(DEFAULT_OPTIONS_GENERATOR).
               merge(options)
    @cache   = {}
  end

  # @since 0.2.0
  def separator!
    @seps[@rows.length] += 1
    nil
  end
  
  # @param [Array] row
  # @since 0.2.0
  def << row
    @rows << row
    nil
  end

  # @return [String]
  # @since 0.2.0
  def to_s
    return nil if @rows.empty?

    # Invalidate cache if needed
    num_cached_rows = @cache[:num_rows] || 0
    analysis = Tabularize.analyze(@rows[num_cached_rows..-1], @options.merge(@cache[:analysis] || {}))

    unless @cache.empty?
      cmw = @cache[:analysis][:max_widths]
      mw  = analysis[:max_widths]
      if mw.zip(cmw).any? { |pair| pair.first > (pair.last || 0) }
        @cache = {}
        num_cached_rows = 0
      else
        [@seps[@rows.length] - @cache[:last_seps], 0].max.times do
          @cache[:string_io].puts @cache[:separator]
        end
        @cache[:last_seps] = @seps[@rows.length]

        if num_cached_rows == @rows.length
          return @cache[:string_io].string + @cache[:separator]
        end
      end
    end
    
    rows = Tabularize.it(@rows[num_cached_rows..-1], @options.merge(analysis))

    h  = @options[:hborder]
    v  = @options[:vborder]
    i  = @options[:iborder]
    vl = @options[:vborder]
    il = @options[:iborder]
    u  = @options[:unicode]
    a  = @options[:ansi]
    sw = @options[:screen_width]
    el = @options[:ellipsis].length

    separator = @cache[:separator]
    col_count = @cache[:col_count]
    unless separator
      separator = ''
      rows[0].each_with_index do |c, idx|
        new_sep = separator + i + h * Tabularize.cell_width(c, u, a)

        if sw && Tabularize.cell_width(new_sep, u, a) > sw - el
          col_count = idx
          break
        else
          separator = new_sep
        end
      end
      separator += il
    end

    output = @cache[:string_io] || StringIO.new.tap { |io| io.puts separator }
    if col_count
      rows = rows.map { |line| line[0, col_count] }
      vl = il = @options[:ellipsis]
    end
    rows.each_with_index do |row, idx|
      row = row.map { |val| val.lines.to_a.map(&:chomp) }
      height = row[0] ? row[0].count : 1
      @seps[idx + num_cached_rows].times do
        output.puts separator
      end
      (0...height).each do |line|
        output.print v unless row.empty?
        output.puts row.map { |lines|
          lines[line] || @options[:pad] * Tabularize.cell_width(lines[0], u, a)
        }.join(v) + vl
      end
    end

    @seps[rows.length + num_cached_rows].times do
      output.puts separator
    end

    @cache = {
      :analysis  => analysis,
      :separator => separator,
      :col_count => col_count,
      :num_rows  => @rows.length,
      :string_io => output,
      :last_seps => @seps[rows.length]
    }
    output.string + separator
  rescue Exception
    @cache = {}
    raise
  end

  # Returns the display width of a String
  # @param [String] str Input String
  # @param [Boolean] unicode Set to true when the given String can include CJK wide characters
  # @param [Boolean] ansi Set to true When the given String can include ANSI codes
  # @return [Fixnum] Display width of the given String
  # @since 0.2.0
  def self.cell_width str, unicode, ansi
    str = str.gsub(/\e\[\d*(?:;\d+)*m/, '') if ansi
    str.send(unicode ? :display_width : :length)
  end

  # Determines maximum widths of cells and maximum heights of rows
  def self.analyze data, options = {}
    unicode     = options[:unicode]
    ansi        = options[:ansi]
    max_widths  = (options[:max_widths] || []).dup
    max_heights = (options[:max_heights] || []).dup
    rows        = []

    data.each_with_index do |row, ridx|
      rows << row = [*row].map(&:to_s)

      row.each_with_index do |cell, idx|
        nlines = 0
        cell.lines do |c|
          max_widths[idx] = [ Tabularize.cell_width(c.chomp, unicode, ansi), max_widths[idx] || 0 ].max
          nlines += 1
        end
        max_heights[ridx] = [ nlines, max_heights[ridx] || 1 ].max
      end
    end

    num_cells = max_widths.length
    rows.each do |row|
      [num_cells - row.length, 0].max.times do
        row << ''
      end
    end

    {
      :rows        => rows,
      :max_widths  => max_widths,
      :max_heights => max_heights,
    }
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
    align   = [*options[:align]]
    valign  = [*options[:valign]]
    unicode = options[:unicode]
    ansi    = options[:ansi]
    screenw = options[:screen_width]

    unless pad.length == 1
      raise ArgumentError.new("Invalid padding") 
    end
    unless padl.is_a?(Fixnum) && padl >= 0
      raise ArgumentError.new(":pad_left must be a non-negative integer")
    end
    unless padr.is_a?(Fixnum) && padr >= 0
      raise ArgumentError.new(":pad_right must be a non-negative integer")
    end
    unless align.all? { |a| [:left, :right, :center].include?(a) }
      raise ArgumentError.new("Invalid alignment")
    end
    unless valign.all? { |a| [:top, :bottom, :middle].include?(a) }
      raise ArgumentError.new("Invalid vertical alignment")
    end
    unless screenw.nil? || (screenw.is_a?(Fixnum) && screenw > 0)
      raise ArgumentError.new(":screen_width must be a positive integer")
    end

    # Analyze data
    ret = options[:analysis] || Tabularize.analyze(table_data, options)
    rows, max_widths, max_heights =
      [:rows, :max_widths, :max_heights].map { |k| ret[k] }

    ridx = -1
    rows.map { |row| 
      ridx += 1
      idx = -1
      max_height = max_heights[ridx]
      row.map { |cell|
        idx += 1
        lines = cell.to_s.lines.to_a
        offset =
          case valign[idx] || valign.last
          when :top
            0
          when :bottom
            max_height - lines.length
          when :middle
            (max_height - lines.length) / 2
          end

        (0...max_height).map { |ln|
          ln -= offset
          str = (ln >= 0 && lines[ln]) ? lines[ln].chomp : (pad * max_widths[idx])
          alen = 
            if ansi
              Tabularize.cell_width(str, false, false) -
                Tabularize.cell_width(str, false, true)
            else
              0
            end
          slen = str.length - alen

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
        }.join($/)
      }
    }
  end
end
