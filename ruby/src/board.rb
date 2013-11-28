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

  def four_in_row_color
    color = nil
    @items.each_index do |i|
      @items[i].each_index do |j|
        if @items[i][j] != Connect4::EMPTY
          if four_right?(i, j) || four_down?(i, j) || four_diag_down?(i, j) || four_diag_up?(i, j)
            color = @items[i][j]
          end
        end
      end
    end
    color
  end

  private

  def four_consecutive?(i, j, delta_i, delta_j)
    base = @items[i][j]

    elems = (1..3).map do |k|
      row = @items[i + k * delta_i]
      if row
        row[j + k * delta_j]
      else
        nil
      end
    end

    elems.all? do |e|
      e == base
    end
  end

  def four_right?(i, j)
    four_consecutive?(i, j, 0, 1)
  end

  def four_down?(i, j)
    four_consecutive?(i, j, 1, 0)
  end

  def four_diag_up?(i, j)
    four_consecutive?(i, j, -1, 1)
  end

  def four_diag_down?(i, j)
    four_consecutive?(i, j, 1, 1)
  end
end
