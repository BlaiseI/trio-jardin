class_name LevelSelector
extends Node2D

var game: Game
var gardeningRectangles: Array = []
var panelOpened: bool = false

func saveParameters() -> void:
	var parametersDictionary: Dictionary = {
		"actualLevel":Global.actualLevel,
		"harvestingPlant":  Global.harvestingPlant,
		"gardeningRectangles":[],
		"powerUps": Global.powerUps.duplicate(),
		"seeds": Global.seeds.duplicate(),
		"collectables": Global.collectables.duplicate()
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

	Global.actualLevel = parametersDictionary["actualLevel"]
	Global.seeds = parametersDictionary["seeds"]
	Global.collectables = parametersDictionary["collectables"]
	Global.harvestingPlant = parametersDictionary["harvestingPlant"]
	for gardeningRectangleDict: Dictionary in parametersDictionary["gardeningRectangles"]:
		var gardeningRectangle : GardeningRectangle = GardeningRectangle.fromDict(gardeningRectangleDict)
		gardeningRectangles.append(gardeningRectangle)
		add_child(gardeningRectangle)
	Global.powerUps = parametersDictionary["powerUps"]

func _ready() -> void:
	loadParameters("res://gameSave/save.json")
	#saveParameters()

func update() -> void:
	for gardeningRectangle : GardeningRectangle in gardeningRectangles:
		gardeningRectangle.update(Global.actualLevel)

func _process(delta: float) -> void:
	pass

func _on_play_button_pressed() -> void:
	var game: Game = get_parent()
	game.launchLevel(Global.actualLevel)

func _on_plant_to_seed_button_pressed() -> void:
	gardeningRectangles[0].openPanel("seedPanel")
	pass
