require "tabularize/version"

module Tabularize
  DEFAULT_OPTIONS = {
    :pad => ' ',
    :align => :left,
    :unicode_display => false
  }

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
    align   = options[:align]
    unicode = options[:unicode_display]
    raise ArgumentError.new("Invalid padding") unless pad.length == 1
    raise ArgumentError.new("Invalid alignment") unless
        [:left, :right, :center].include?(align)

    l = 
      if unicode
        require 'unicode/display_width'
        :display_width
      else
        :length
      end

    rows       = []
    max_widths = []
    table_data.each do |row|
      rows << row = [*row].map(&:to_s).map(&:chomp)

      row.each_with_index do |cell, idx|
        max_widths[idx] = [ cell.send(l), max_widths[idx] || 0 ].max
      end
    end

    rows.map { |row| 
      idx = -1
      row.map { |str|
        idx += 1
        w = max_widths[idx]
        if unicode
          w += str.length - str.display_width
        end
        case align
        when :left
          str.ljust(w, pad)
        when :right
          str.rjust(w, pad)
        when :center
          str.rjust((w - str.length) / 2 + str.length, pad).ljust(w, pad)
        end
      }
    }
  end
end
