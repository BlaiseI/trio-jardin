class_name GardeningRectangle
extends Node2D

const gardeningRectangleTemplate:PackedScene = preload("res://Scenes/gardeningRectangle.tscn")
const levelTemplate:PackedScene = preload("res://Scenes/level_scene.tscn")
const levelPanelTemplate:PackedScene = preload("res://Scenes/LevelPanel.tscn")
const cropPanelTemplate:PackedScene = preload("res://Scenes/CropPanel.tscn")
const seedPanelTemplate:PackedScene = preload("res://Scenes/PlantToSeedPanel.tscn")

var id: int
var active: bool
var firstLevel: int
var nbLevels: int
var node: Node2D
var seedPlanted:String = "null"
var timePlanted: float
var seeds: Array = []
var collectables: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update(get_parent().actualLevel)

func update(actualLevel: int) -> void:
	var ratioLevelsDone: float = (actualLevel - firstLevel)/float(nbLevels)
	if ratioLevelsDone < 0:
		active = false
		blacken(0.5)
		$"Button".disabled = true
	else:
		active = true
		blacken(1)
		$"Button".disabled = false
		if ratioLevelsDone < 0.25:
			$background/weeds.texture = load('res://art/Finished/level selection/weeds_1.png')
		elif ratioLevelsDone < 0.5:
			$background/weeds.texture = load('res://art/Finished/level selection/weeds_2.png')
		elif ratioLevelsDone < 0.75:
			$background/weeds.texture = load('res://art/Finished/level selection/weeds_3.png')
		elif ratioLevelsDone < 1:
			$background/weeds.texture = load('res://art/Finished/level selection/weeds_4.png')
		else:
			$background/weeds.texture = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func blacken(intensity: float) -> void:
	$"background".modulate.r = intensity
	$"background".modulate.g = intensity
	$"background".modulate.b = intensity

func toDict() -> Dictionary:
	print(timePlanted)
	return {
		"id": id,
		"position": position,
		"active": active,
		"firstLevel": firstLevel,
		"nbLevels": nbLevels,
		"seedPlanted": seedPlanted,
		"timePlanted": timePlanted
	}

static func fromDict(parametersDictionary: Dictionary) -> GardeningRectangle:
	var gardeningRectangle : GardeningRectangle = gardeningRectangleTemplate.instantiate()
	gardeningRectangle.id = parametersDictionary["id"]
	gardeningRectangle.position = str_to_var("Vector2" + parametersDictionary["position"])
	gardeningRectangle.firstLevel = parametersDictionary["firstLevel"]
	gardeningRectangle.nbLevels = parametersDictionary["nbLevels"]
	gardeningRectangle.seedPlanted = parametersDictionary["seedPlanted"]
	gardeningRectangle.timePlanted = parametersDictionary["timePlanted"]
	return gardeningRectangle

func openPanel(type:String = "levelPanel") -> void:
	if(get_parent().panelOpened):
		print("panel already opened")
		return
	get_parent().panelOpened = true
	if (type == "levelPanel"):
		var actualLevel = $"..".actualLevel
		var levelPanel: LevelPanel = levelPanelTemplate.instantiate()
		levelPanel.actualLevel = actualLevel
		levelPanel.firstLevel = firstLevel
		levelPanel.nbLevels = nbLevels
		levelPanel.position = (Vector2(576, 1024) - levelPanel.size)/2
		levelPanel.z_index = 1
		levelPanel.name = "levelPanel"
		$"CanvasLayer".add_child(levelPanel)
		var spawned : Signal = levelPanel.spawn()
		await spawned
		return
	elif(type == "cropPanel"):
		var cropPanel: CropPanel = cropPanelTemplate.instantiate()
		cropPanel.position = (Vector2(576, 1024) - cropPanel.size)/2
		cropPanel.z_index = 1
		cropPanel.name = "cropPanel"
		cropPanel.seedPlanted = seedPlanted
		cropPanel.timePlanted = timePlanted
		cropPanel.seedsParams = seeds
		$"CanvasLayer".add_child(cropPanel)
		var spawned : Signal = cropPanel.spawn()
		await spawned
		return
	elif(type == "seedPanel"):
		var seedPanel: SeedPanel = seedPanelTemplate.instantiate()
		seedPanel.position = (Vector2(576, 1024) - seedPanel.size)/2
		seedPanel.z_index = 1
		seedPanel.name = "seedPanel"
		seedPanel.plantsParams = collectables
		seedPanel.seedsParams = seeds
		$"CanvasLayer".add_child(seedPanel)
		var spawned : Signal = seedPanel.spawn()
		await spawned
		return
	else:
		print("panel type not found : " + type)

func closePanel() -> void:
	var panel = find_child("*Panel", true, false)
	panel.queue_free()
	remove_child(panel)
	get_parent().panelOpened = false
	return

func changePanel() -> void:
	var panelType = find_child("*Panel", true, false).name
	closePanel()
	if panelType == ("levelPanel"):
		openPanel("cropPanel")
	else:
		openPanel("levelPanel")
	return
