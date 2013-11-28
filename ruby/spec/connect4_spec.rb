require './src/connect4.rb'

describe Connect4 do

  before(:each) do
    @io = mock("io")
    @game = Connect4.new(@io)
  end

  # Make sure the game doesn't incorrectly think there's a winner.
  describe "detects non-winning conditions" do
    def expect_no_win(items)
      @game.board = Board.new(items)
      expect(@game.has_winner?).to be_false
    end

    it "starts with no winner" do
      expect_no_win(@game.board.items)
    end

    it "no wins for 3 connections" do
      items = [
        %w(. . . . . . .),
        %w(. . . . . . .),
        %w(. R Y Y Y . .),
        %w(R Y R R R . .),
        %w(R R Y Y R R .),
        %w(Y Y Y R Y R Y)
      ]
      expect_no_win(items)
    end
  end

  describe "detects winning conditions" do
    def expect_win(items, player)
      @game.board = Board.new(items)
      expect(@game.has_winner?).to be_true
      expect(@game.get_winner).to be player
    end

    it "finds a horizontal win" do
      items = [
        %w(. . . . . . .),
        %w(. . . . . . .),
        %w(. . Y . . . .),
        %w(. R R R R . .),
        %w(R R Y Y Y . .),
        %w(R Y Y R Y . .)
      ]
      expect_win(items, @game.get_player_by_color(Connect4::RED))
    end

    it "finds a vertical win" do
      items = [
        %w(. . . . . . .),
        %w(. . . . . . .),
        %w(. . Y . . . .),
        %w(R R Y R R . .),
        %w(R Y Y Y R . .),
        %w(R Y Y R Y . .)
      ]
      expect_win(items, @game.get_player_by_color(Connect4::YELLOW))
    end

    it "finds a up-right diagonal win" do
      items = [
        %w(. . . . . . .),
        %w(. . . . . . .),
        %w(. . Y R . . .),
        %w(R Y R R R . .),
        %w(R R Y Y R Y .),
        %w(R Y Y R Y Y .)
      ]
      expect_win(items, @game.get_player_by_color(Connect4::RED))
    end

    it "finds a down-right diagonal win" do
      items = [
        %w(. . . . . . .),
        %w(. . . . . . .),
        %w(. . Y Y . . .),
        %w(Y R R Y Y . .),
        %w(Y R R R Y R .),
        %w(Y R Y R R Y .)
      ]
      expect_win(items, @game.get_player_by_color(Connect4::YELLOW))
    end
  end

  describe "rejects invalid moves" do
    it "detects when column is too small" do
      @game.put(-1).should be_false
    end

    it "detects when column is too large" do
      @game.put(Board::DEFAULT_COLUMN_COUNT).should be_false
    end

    it "detects when column is full" do
      items = [
        %w(. . Y . . . .),
        %w(. . Y . . . .),
        %w(. . R R . . .),
        %w(R Y Y R R . .),
        %w(R Y Y Y R Y .),
        %w(R Y R Y Y R .)
      ]
      @game.board = Board.new(items)
      @game.put(2).should be_false
    end
  end

  it "detects a full board" do
    items = [
      %w(R Y R Y R Y R),
      %w(R Y R Y R Y R),
      %w(Y R Y R Y R Y),
      %w(R Y R Y R Y R),
      %w(R Y R Y R Y R),
      %w(R Y R Y R Y R),
    ]
    @game.board = Board.new(items)
    @game.is_full?.should be_true
  end

  def set_expectations(expectations)
    invalid_move_count = (expectations[:invalid_move_count] || 0)

    expected_prompts = expectations[:moves].length
    expected_boards = expected_prompts - invalid_move_count + 2

    @io.should_receive(:display_board).with(@game.board).exactly(expected_boards).times

    @io.should_receive(:prompt).exactly(expected_prompts).times {
      expectations[:moves].shift
    }

    @io.should_receive(:invalid_move_msg).exactly(invalid_move_count).times

    if expectations[:winner]
      @io.should_receive(:winner_msg).with(expectations[:winner])
    end

    if expectations[:full_board_msg]
      @io.should_receive(:full_board_msg)
    end
  end

  describe "has correct game flow" do
    it "ends game on win" do
      moves = [0, 1, 0, 1, 0, 1, 2, 1]
      set_expectations({
        moves: moves,
        winner: @game.players[1]
      })
      @game.play
    end

    it "prompts on an invalid move" do
      # Implicitly, this verifies that the player who made the invalid move gets
      # to retry; otherwise, there would be no winner after this sequence of
      # moves.
      moves = [0, 1, 0, 1, 0, -1, 1, 0]
      set_expectations({
        moves: moves,
        invalid_move_count: 1,
        winner: @game.players[0]
      })
      @game.play
    end

    it "complains and exits on a full board" do
      # Set the board to empty so we don't have to figure out a sequence of
      # moves to create a full board.
      @game.board = Board.new([[]])

      set_expectations({
        moves: [],
        full_board_msg: true
      })

      @game.play
    end
  end
end
