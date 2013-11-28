package com.sidnair

import scala.util.Try

trait IOHelper {
  def readIntOpt: Option[Int]
  def write(s: String): Unit
  def writeln(s: String): Unit
}

trait ConsoleIOHelper extends IOHelper {
  override def readIntOpt: Option[Int] = (Try(Console.readInt - 1)).toOption

  override def write(s: String): Unit = Console.print(s)

  override def writeln(s: String): Unit = Console.println(s)
}

abstract class TextMessager extends IOHelper {
  def showBoard(board: Board): Unit = {
    writeln(List.fill(100)("\n").mkString)
    writeln(board.toString)
  }

  def declareWinner(player: Player): Unit = writeln("Player " + player.id + " has won!")

  def invalidMoveMsg: Unit = writeln("Invalid move. Try again.")

  def prompt(player: Player): Option[Int] = {
    write("Player " + player.id + ", please enter a number: ")
    readIntOpt
  }
}

class ConsoleIO extends TextMessager with ConsoleIOHelper
