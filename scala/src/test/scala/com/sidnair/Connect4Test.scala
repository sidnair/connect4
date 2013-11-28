package com.sidnair

import org.scalatest.FunSpec
import org.scalatest.mock.EasyMockSugar
import org.easymock.EasyMock.anyObject
import org.easymock.EasyMock

protected abstract class TestIO extends TextMessager with IOHelper {
  def write(s: String): Unit = {}
  def writeln(s: String): Unit = {}
}

protected object TestIO {
  def apply(_inputs: List[Int]): TestIO = {
    var inputs = _inputs
    new TestIO {
      override def readIntOpt: Option[Int] = {
        val ret = inputs.head
        inputs = inputs.tail
        Some(ret)
      }
    }
  }

  def empty = apply(List.empty)
}

class Connect4Spec extends FunSpec with EasyMockSugar {
  val p1 = Player(1, Color.Red)
  val p2 = Player(2, Color.Yellow)

  def makeGame(board: Board, io: TextMessager = TestIO.empty): Connect4 = new Connect4(
    io,
    GameState(board, p1, p2, 0)
  )

  describe("correctly identifies no winner") {
    it("starts with no winner") {
      val game = makeGame(Board.empty)
      assert(game.hasWinner == false)
    }

    it("identifies no winners for three connections") {
      val items = Vector(
        ". . . . . . .",
        ". . . . . . .",
        "R R Y Y Y . .",
        "R Y R R R . .",
        "R R Y Y R R .",
        "Y Y Y R Y R Y"
      )

      val game = makeGame(Board(items))
      assert(game.hasWinner == false)
    }
  }

  describe("correctly identifies winner") {
    it("detects a horizontal winner") {
      val items = Vector(
        ". . . . . . .",
        ". . . . . . .",
        ". . . . . . .",
        ". . . . . . .",
        ". Y Y Y . . .",
        ". R R R R . ."
      )
      val game = makeGame(Board(items))
      assert(game.hasWinner == true)
    }

    it("detects a vertical winner") {
      val items = Vector(
        ". . . . . . .",
        ". . . . . . .",
        ". Y . . . . .",
        ". Y R . . . .",
        ". Y R . . . .",
        ". Y R R . . ."
      )
      val game = makeGame(Board(items))
      assert(game.hasWinner == true)
    }

    it("detects an up diagonal winner") {
      val items = Vector(
        ". . . . . . .",
        ". . . . . . .",
        ". R . . Y . .",
        ". R R Y R . .",
        ". Y Y Y R . .",
        "Y Y R R R . ."
      )
      val game = makeGame(Board(items))
      assert(game.hasWinner == true)
    }

    it("detects a down diagonal winner") {
      val items = Vector(
        ". . . . . . .",
        ". . . . . . .",
        ". R . . Y . .",
        ". R R Y Y . .",
        ". Y R R R . .",
        "Y Y R Y R . ."
      )
      val game = makeGame(Board(items))
      assert(game.hasWinner == true)
    }
  }

  describe("detects invalid moves") {
    it("fails on a small column") {
      val game = makeGame(Board.empty)
      assert(game.put(-1, Color.Red) == None)
    }

    it("fails on a large column") {
      val game = makeGame(Board.empty)
      assert(game.put(Board.Columns, Color.Red) == None)
    }

    it("fails on a full column") {
      val items = Vector(
        "R . . . . . .",
        "Y . . . . . .",
        "R R Y Y Y . .",
        "R Y R R R . .",
        "R R Y Y R R .",
        "Y Y Y R Y R Y"
      )
      val game = makeGame(Board(items))

      assert(game.put(0, Color.Red) == None)
    }
  }

  describe("allows a valid move") {
    it("updates the board on a valid move") {
      val game = makeGame(Board.empty)
      val placedColor = Color.Red
      val updatedColor = game.put(0, placedColor).get.state.board.items(Board.Rows - 1)(0)
      assert(updatedColor == placedColor)
    }
  }

  describe("detects full board") {
    it("identifies full board") {
      val items = Vector(
        "R Y R Y R Y R",
        "R Y R Y R Y R",
        "Y R Y R Y R Y",
        "R Y R Y R Y R",
        "R Y R Y R Y R",
        "R Y R Y R Y R"
      )
      val game = makeGame(Board(items))
      assert(game.state.board.isFull == true)
    }

    it("identifies non-full board") {
      val items = Vector(
        ". . . . . . .",
        "R Y R Y R Y R",
        "Y R Y R Y R Y",
        "R Y R Y R Y R",
        "R Y R Y R Y R",
        "R Y R Y R Y R"
      )
      val game = makeGame(Board(items))
      assert(game.state.board.isFull == false)
    }
  }

  describe("maintains correct game flow") {
    def getMockIO(moves: List[Int], winnerOpt: Option[Player], invalidMoveCount: Int = 0): TextMessager = {
      val mockMessager = mock[TextMessager]

      // Once before each valid move and once at the end of the game.
      mockMessager.showBoard(anyObject(null)).times(moves.length - invalidMoveCount + 1)

      moves.foreach(m => mockMessager.prompt(anyObject(null)).andReturn(Some(m)))

      if (invalidMoveCount > 0) {
        mockMessager.invalidMoveMsg.times(invalidMoveCount)
      }

      winnerOpt.foreach(mockMessager.declareWinner)

      mockMessager
    }

    it("ends on a win") {
      val moves = List(0, 1, 0, 1, 0, 1, 2, 1)
      val mockMessager = getMockIO(moves, Some(p2))

      whenExecuting(mockMessager) {
        val endState = makeGame(Board.empty, mockMessager).play
        assert(endState.moveCount == moves.length)
      }
    }

    it("prompts on an invalid move") {
      val moves = List(0, 1, 0, 1, 0, 1, -1, 0)
      val mockMessager = getMockIO(moves, Some(p1), 1)

      whenExecuting(mockMessager) {
        val endState = makeGame(Board.empty, mockMessager).play
        assert(endState.moveCount == moves.length - 1)
      }
    }

    it("exits when the board is full") {
      val mockMessager = getMockIO(List.empty, None)

      whenExecuting(mockMessager) {
        val endState = makeGame(Board(Vector()), mockMessager).play
        assert(endState.moveCount == 0)
      }
    }
  }
}
