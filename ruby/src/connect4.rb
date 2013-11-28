class Connect4
  EMPTY = '.'
  RED = 'R'
  YELLOW = 'Y'

  attr_reader :players
  attr_accessor :board # Allow writing for tests

  def initialize(io)
    @io = io
    @board = Board.new
    @i = 0
    @players = [Player.new(RED, 0), Player.new(YELLOW, 1)]
  end

  def play
    @io.display_board(board)

    while !has_winner? && !is_full?
      column = @io.prompt(current_player)

      if !put(column)
        @io.invalid_move_msg
      else
        @io.display_board(board)
      end
    end

    @io.display_board(board)

    if is_full?
      @io.full_board_msg
    else
      @io.winner_msg(get_winner)
    end
  end

  def put(column)
    if @board.put(column, current_player.color)
      @i += 1
      true
    else
      false
    end
  end

  def is_full?
    @board.is_full?
  end

  def current_player
    @players[@i % @players.length]
  end

  def has_winner?
    get_winner != nil
  end

  def get_player_by_color(color)
    @players.find { |p| p.color == color }
  end

  def get_winner
    winner = nil
    @board.items.each_index do |i|
      @board.items[i].each_index do |j|
        if @board.items[i][j] != EMPTY
          if four_right(i, j) || four_down(i, j) || four_diag_down(i, j) || four_diag_up(i, j)
            winner = get_player_by_color(@board.items[i][j])
          end
        end
      end
    end

    winner
  end

  private

  def four_consecutive(i, j, delta_i, delta_j)
    base = @board.items[i][j]

    elems = (1..3).map do |k|
      row = @board.items[i + k * delta_i]
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

  def four_right(i, j)
    four_consecutive(i, j, 0, 1)
  end

  def four_down(i, j)
    four_consecutive(i, j, 1, 0)
  end

  def four_diag_up(i, j)
    four_consecutive(i, j, -1, 1)
  end

  def four_diag_down(i, j)
    four_consecutive(i, j, 1, 1)
  end
end
