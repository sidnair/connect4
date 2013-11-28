# IO class used for sending input to the user via console. Could theoretically
# be replaced with a fancy GUI, stub IO, etc.
class BasicIO
  def initialize(input, output)
    @input = input
    @output = output
  end

  def invalid_move_msg
    @output.puts "Invalid move. Try again.\n"
  end

  def display_board(board)
    @output.puts "\n" * 100
    @output.puts board
    @output.puts "\n"
  end

  def full_board_msg
    @output.puts "The board is full. Ending game."
  end

  def winner_msg(player)
    @output.puts "Player #{player.id} wins!"
  end

  # Converts 1-based index input to 0-based index int. On invalid input, this
  # returns -1.
  def prompt(player)
    @output.puts "Player #{player.id} - please enter a column: "
    @input.gets.to_i - 1
  end
end
