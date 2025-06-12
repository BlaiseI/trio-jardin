class_name LevelSelector
extends Node2D

var actualLevel: int
var nbGardeningRectangles: int
var gardeningRectangles: Array = []

func saveParameters() -> void:
	var parametersDictionary: Dictionary = {
		"actualLevel":actualLevel,
		"nbGardeningRectangles":nbGardeningRectangles,
		"gardeningRectangles":[],
	}
	for gardeningRectangle : GardeningRectangle in gardeningRectangles:
		parametersDictionary["gardeningRectangles"].append(gardeningRectangle.toDict())
	DirAccess.make_dir_recursive_absolute("res://gameSave")
	var filePath: String = "res://gameSave/save.json"
	var saveFile = FileAccess.open(filePath, FileAccess.WRITE_READ)
	var parametersJSONString:String = JSON.stringify(parametersDictionary)
	saveFile.store_line(parametersJSONString)

func loadParameters(filePath: String) -> void:
	var saveFile:FileAccess = FileAccess.open(filePath, FileAccess.READ)
	var paramsJSONString = saveFile.get_line()
	var paramsJSON = JSON.new()
	paramsJSON.parse(paramsJSONString)
	var parametersDictionary: Dictionary = paramsJSON.data

	actualLevel = parametersDictionary["actualLevel"]
	nbGardeningRectangles = parametersDictionary["nbGardeningRectangles"]
	for gardeningRectangleDict: Dictionary in parametersDictionary["gardeningRectangles"]:
		var gardeningRectangle : GardeningRectangle = GardeningRectangle.fromDict(gardeningRectangleDict)
		gardeningRectangles.append(gardeningRectangle)
		add_child(gardeningRectangle)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadParameters("res://gameSave/save.json")
	#saveParameters()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
