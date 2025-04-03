extends Node

func createLevel() -> void:
	var parametersDictionary: Dictionary = {
		"gridHeight":8,
		"gridWidth":8,
		"emptyTiles":[],
		"nbCarrots":1,
		"blockTypeCondition1":"Chardon",
		"numberForCondition1":11,
		"numberMovesLeft":3
	}
	parametersDictionary["emptyTiles"].append(Vector2(3,4))
	var levelName: String = "1"
	Level.saveParameters(parametersDictionary, levelName)

func _ready() -> void:
	#createLevel()
	pass
