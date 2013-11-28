package com.sidnair

class Board(val items: Vector[Vector[Color.Value]]) {
  def put(col: Int, color: Color.Value): Option[Board] = {
    val i = items.lastIndexWhere(_.lift(col).exists(_ == Color.Empty))
    if (i >= 0) {
      Some(new Board(items.updated(i, items(i).updated(col, color))))
    } else {
      None
    }
  }

  def isFull: Boolean = !items.exists(_.exists(_ == Color.Empty))

  def hasConnectedFour: Boolean = (for {
    (row, i) <- items.zipWithIndex
    (color, j) <- row.zipWithIndex
    if color != Color.Empty
    if hasConnectedFourAt(color, i, j)
  } yield true).length > 0

  override def toString: String = {
    val content = items.map(_.mkString("\t"))
    val numbers = (1 to Board.Columns).toList.mkString("\t")
    (content ++ List(numbers)).mkString("\n\n\n") + "\n\n"
  }

  private def hasConnectedFourAt(color: Color.Value, i: Int, j: Int) = {
    hasConnectedFourHorizontally(color, i, j) || hasConnectedFourVertically(color, i, j) ||
        hasConnectedFourUpDiagonally(color, i, j) || hasConnectedFourDownDiagonally(color, i, j)
  }

  private def hasConnectedHelper(
    color: Color.Value,
    i: Int,
    j: Int,
    deltaI: Int,
    deltaJ: Int,
    remaining: Int = 4
  ): Boolean = {
    if (remaining == 0) {
      true
    } else {
      val currentCellMatches = items.lift(i).exists(row => { row.lift(j).exists(_ == color) })
      currentCellMatches && hasConnectedHelper(color, i + deltaI, j + deltaJ, deltaI, deltaJ, remaining - 1)
    }
  }

  private def hasConnectedFourVertically(color: Color.Value, i: Int, j: Int): Boolean =
      hasConnectedHelper(color, i, j, 1, 0)

  private def hasConnectedFourHorizontally(color: Color.Value, i: Int, j: Int): Boolean =
      hasConnectedHelper(color, i, j, 0, 1)

  private def hasConnectedFourUpDiagonally(color: Color.Value, i: Int, j: Int): Boolean =
      hasConnectedHelper(color, i, j, -1, 1)

  private def hasConnectedFourDownDiagonally(color: Color.Value, i: Int, j: Int): Boolean =
      hasConnectedHelper(color, i, j, 1, 1)
}

object Board {
  val Rows = 6
  val Columns = 7

  def apply(_items: Vector[String]) = {
    val items = _items.map(row => {
      Vector(row.split(" "): _*).map(Color.withName)
    })
    new Board(items)
  }

  def empty = new Board(Vector.fill(Rows, Columns)(Color.Empty))
}
