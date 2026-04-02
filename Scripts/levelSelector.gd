class_name LevelSelector
extends Node2D

var game: Game
var actualLevel: int
var nbGardeningRectangles: int
var gardeningRectangles: Array = []
var panelOpened: bool = false
var seedsParams: Array = []
var collectables: Array

func saveParameters() -> void:
	var parametersDictionary: Dictionary = {
		"actualLevel":actualLevel,
		"nbGardeningRectangles":nbGardeningRectangles,
		"harvestingPlant":  game.harvestingPlant,
		"gardeningRectangles":[],
		"powerUps":{},
		"seeds":[],
		"collectables":[]
	}
	for gardeningRectangle : GardeningRectangle in gardeningRectangles:
		parametersDictionary["gardeningRectangles"].append(gardeningRectangle.toDict())
	parametersDictionary["powerUps"] = Global.powerUps.duplicate()
	parametersDictionary["seeds"] = seedsParams.duplicate()
	parametersDictionary["collectables"] = collectables.duplicate()
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
	seedsParams = parametersDictionary["seeds"]
	collectables = parametersDictionary["collectables"]
	game.harvestingPlant = parametersDictionary["harvestingPlant"]
	for gardeningRectangleDict: Dictionary in parametersDictionary["gardeningRectangles"]:
		var gardeningRectangle : GardeningRectangle = GardeningRectangle.fromDict(gardeningRectangleDict)
		gardeningRectangle.seeds = seedsParams
		gardeningRectangle.collectables = collectables
		gardeningRectangle.harvestingPlant = game.harvestingPlant
		gardeningRectangles.append(gardeningRectangle)
		add_child(gardeningRectangle)
	Global.powerUps = parametersDictionary["powerUps"]

func _ready() -> void:
	loadParameters("res://gameSave/save.json")
	#saveParameters()

func update() -> void:
	for gardeningRectangle : GardeningRectangle in gardeningRectangles:
		gardeningRectangle.update(actualLevel)

func updateSeeds(newSeedsParams : Array) -> void:
	seedsParams = newSeedsParams
	for gardeningRectangle: GardeningRectangle in gardeningRectangles:
		gardeningRectangle.seeds = seedsParams
	saveParameters()

func updatePlants(newPlantsParams : Array) -> void:
	collectables = newPlantsParams
	gardeningRectangles[0].collectables = collectables
	saveParameters()

func updateHarvesting(newHarvestingPlant: String) -> void:
	game.harvestingPlant = newHarvestingPlant
	for gardeningRectangle: GardeningRectangle in gardeningRectangles:
		gardeningRectangle.harvestingPlant = game.harvestingPlant
	saveParameters()

func addPowerUps(type: String, number: int)-> void:
	for powerUp: Dictionary in Global.powerUps:
		if powerUp["type"] == type:
			powerUp["number"] += number
			break
	saveParameters()

func updateCollectables(type: String) -> void:
	for collectable : Array in collectables:
		if collectable[0] == type:
			collectable[1] += 1
	saveParameters()
	return

func _process(delta: float) -> void:
	pass

func _on_play_button_pressed() -> void:
	var game: Game = get_parent()
	game.launchLevel(actualLevel)


func _on_plant_to_seed_button_pressed() -> void:
	gardeningRectangles[0].openPanel("seedPanel")
	pass
