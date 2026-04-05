class_name SeedPanel
extends Control

static var seedPreload = preload("res://Scenes/seed.tscn")
static var plantPreload = preload("res://Scenes/plant.tscn")

var seedsParams: Array = Global.seeds
var seeds: Array = []
var plantsParams: Array = Global.collectables
var plants: Array = []
var selectedPlant: String

func _ready() -> void:
	$CloseButton.pressed.connect($"../../".closePanel)
	for i in range(seedsParams.size()):
		var seed = seedPreload.instantiate()
		seed.position = Vector2(108 + (i%5)*54, 336 + (i/5)*54)
		seed.type = seedsParams[i]["type"]
		seed.name = seed.type
		seed.number = seedsParams[i]["number"]
		seed.pressed.disconnect(seed._onButtonPressed)
		add_child(seed)
		seeds.append(seed)
	for i in range(plantsParams.size()):
		var plant = plantPreload.instantiate()
		plant.position = Vector2(108 + (i%5)*54, 42 + (i/5)*54)
		plant.type = plantsParams[i]["type"]
		plant.name = plant.type
		plant.number = plantsParams[i]["number"]
		add_child(plant)
		plants.append(plant)
	if(Global.harvestingPlant != "null"):
		$harvestingPlant.visible = true
		$harvestingPlant.texture = Plant.plantTextures[Global.harvestingPlant]

func spawn() -> Signal:
	self.scale = Vector2(0.1,0.1)
	var tween:Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), .3)
	return tween.finished

func activateTileAndArrow(plant: Plant) -> void:
	$"Tile".position = plant.position - Vector2(6,6)
	$"Tile".visible = true
	$"Tile".modulate.b = 0
	$"Gather".visible = true
	$"Gather".modulate.b = 0
	$"Arrow".visible = true
	if(plant.number >= 1):
		$"Arrow".modulate.r = 0
		$"Arrow".modulate.g = 1
		$"Arrow".modulate.b = 0
	else:
		$"Arrow".modulate.r = 1
		$"Arrow".modulate.g = 0
		$"Arrow".modulate.b = 0
	pass

func selectPlant(type: String) -> void:
	selectedPlant = type
	for plant: Plant in plants:
		if plant.type == type:
			activateTileAndArrow(plant)
	pass

func _on_arrow_pressed() -> void:
	var type: String = selectedPlant
	for i in range(plants.size()):
		var plant: Plant = plants[i]
		if plant.type == type:
			if plant.number < 1:
				print("not enough plant")
				return
			plantsParams[i]["number"] -= 1
			plant.setNumber(plant.number - 1)
			seedsParams[i]["number"] += 1
			seeds[i].setNumber(seeds[i].number + 1)
			$"../../../".saveParameters()
			activateTileAndArrow(plant)
	return


func _on_gather_pressed() -> void:
	Global.harvestingPlant = selectedPlant
	$harvestingPlant.visible = true
	$harvestingPlant.texture = Plant.plantTextures[Global.harvestingPlant]
	$"../../../".saveParameters()
	return

func _on_clear_plant_pressed() -> void:
	Global.harvestingPlant = "null"
	$harvestingPlant.visible = false
	$harvestingPlant.texture = null
	$"../../../".saveParameters()
	pass
