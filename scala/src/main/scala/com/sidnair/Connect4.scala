package com.sidnair

case class GameState(board: Board, currentPlayer: Player, waitingPlayer: Player, moveCount: Int)

object GameState {
  def empty(p1: Player, p2: Player): GameState = GameState(Board.empty, p1, p2, 0)
}

class Connect4(messager: TextMessager, val state: GameState) {
  def play: GameState = {
    if (!isDone) {
      messager.showBoard(state.board)
      makeMove.play
    } else {
      messager.showBoard(state.board)

      if (hasWinner) {
        messager.declareWinner(state.waitingPlayer)
      }

      state
    }
  }

  private[sidnair] def hasWinner = state.board.hasConnectedFour

  private[sidnair] def put(col: Int, color: Color.Value): Option[Connect4] = {
    state.board.put(col, color).map(newBoard => {
      new Connect4(
        messager,
        GameState(
          board = newBoard,
          currentPlayer = state.waitingPlayer,
          waitingPlayer = state.currentPlayer,
          moveCount = state.moveCount + 1
        )
      )
    })
  }

  private def makeMove: Connect4 = {
    messager.prompt(state.currentPlayer).flatMap(move => {
      put(move, state.currentPlayer.color)
    }).getOrElse {
      messager.invalidMoveMsg
      makeMove
    }
  }

  private def isFull = state.board.isFull

  private def isDone: Boolean = hasWinner || isFull
}
