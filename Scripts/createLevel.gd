extends Node

func createLevel() -> void:
	var parametersDictionary: Dictionary = {
		"gridHeight":8,
		"gridWidth":8,
		"gridEmptyTiles":[],
		"nbCarrots":1,
		"blockTypeForCondition1":"Chardon",
		"numberForCondition1":11,
		"numberMovesLeft":3
	}
	parametersDictionary["gridEmptyTiles"].append(Vector2(3,4))
	parametersDictionary["gridEmptyTiles"].append(Vector2(4,3))
	var levelName: String = "1"
	Level.saveParameters(parametersDictionary, levelName)

func _ready() -> void:
	createLevel()
	pass
