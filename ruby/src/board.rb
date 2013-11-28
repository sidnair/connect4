class Board
  attr_reader :items

  DEFAULT_ROW_COUNT = 6
  DEFAULT_COLUMN_COUNT = 7

  def initialize(items = Array.new(DEFAULT_ROW_COUNT) { Array.new(DEFAULT_COLUMN_COUNT, Connect4::EMPTY) })
    @items = items
  end

  # Tries to puts a color in a column. Returns true iff the move is valid.
  def put(column, color)
    bottom_row = @items.reverse_each.find do |row|
      row[column] == Connect4::EMPTY && column >= 0
    end

    if bottom_row
      bottom_row[column] = color
      true
    else
      false
    end
  end

  def is_full?
    !@items[0].include?(Connect4::EMPTY)
  end

  def to_s
    def format_row(arr)
      "\t" + arr.join("\t")
    end

    vertical_spacing = "\n\n\n"

    content = (@items.map do |arr|
      format_row(arr)
    end).join(vertical_spacing)
    labels = format_row((0..@items.length).map { |i| i + 1 })

    content + vertical_spacing + labels
  end
end
