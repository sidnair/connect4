class StdIO
  def initialize(input)
    @input = input
  end

  def invalid_move_msg
    puts "Invalid move. Try again.\n"
  end

  def display_board(board)
    puts "\n" * 100
    puts board
    puts "\n"
  end

  def full_board_msg
    puts "The board is full. Ending game."
  end

  def winner_msg(player)
    puts "Player #{player.id} wins!"
  end

  # Converts 1-based index input to 0-based index int. On invalid input, this
  # returns -1.
  def prompt(player)
    puts "Player #{player.id} - please enter a column: "
    @input.gets.to_i - 1
  end
end
