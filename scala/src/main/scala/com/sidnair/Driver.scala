package com.sidnair

object Driver {
  def main(args: Array[String]): Unit = {
    val p1 = Player(1, Color.Red)
    val p2 = Player(2, Color.Yellow)
    new Connect4(new ConsoleIO, GameState.empty(p1, p2)).play
  }
}
