extends Node

func createLevel() -> void:
	var parametersDictionary: Dictionary = {
		"gridHeight":8,
		"gridWidth":8,
		"gridEmptyTiles":[],
		"gridRonce" : [],
		"gridLierre" : [],
		"fixedBlocks" : [],
		"nbDifferentBlocks":4,
		"nbCarrots":1,
		"ConditionType1":"chardon",
		"numberForCondition1":11,
		"ConditionType2":"null",
		"numberForCondition2":0,
		"numberMovesLeft":3
	}
	parametersDictionary["gridEmptyTiles"].append(Vector2(3,4))
	parametersDictionary["gridEmptyTiles"].append(Vector2(4,3))
	parametersDictionary["gridRonce"].append(Vector2(0,7))
	var levelName: String = "1"
	Level.saveParameters(parametersDictionary, levelName)

func _ready() -> void:
	createLevel()
	pass
