class_name Position
extends Object

var row: int
var column: int

func _init(rowValue: int, columnValue: int):
	row = rowValue
	column = columnValue

static func getNull() -> Position:
	return Position.new(-1, -1)

func equals(other:Position) -> bool:
	return row == other.row && column == other.column
