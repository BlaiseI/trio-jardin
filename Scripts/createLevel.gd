extends Node

func createLevel() -> void:
	var parametersDictionary: Dictionary = {
		"gridHeight":8,
		"gridWidth":8,
		"gridEmptyTiles":[],
		"gridWebs" : [],
		"gridRonce" : [],
		"nbCarrots":1,
		"ConditionType1":"Chardon",
		"numberForCondition1":11,
		"ConditionType2":"null",
		"numberForCondition2":0,
		"numberMovesLeft":3
	}
	parametersDictionary["gridEmptyTiles"].append(Vector2(3,4))
	parametersDictionary["gridEmptyTiles"].append(Vector2(4,3))
	parametersDictionary["gridWebs"].append(Vector2(1,2))
	parametersDictionary["gridWebs"].append(Vector2(3,1))
	parametersDictionary["gridRonce"].append(Vector2(0,7))
	var levelName: String = "1"
	Level.saveParameters(parametersDictionary, levelName)

func _ready() -> void:
	createLevel()
	pass
