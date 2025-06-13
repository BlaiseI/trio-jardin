class_name GardeningRectangle
extends Node2D

const gardeningRectangleTemplate:PackedScene = preload("res://Scenes/gardeningRectangle.tscn")
const levelTemplate:PackedScene = preload("res://Scenes/level_scene.tscn")

var id: int
var active: bool
var firstLevel: int
var nbLevels: int
var node: Node2D

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
	return {
		"id": id,
		"position": position,
		"active": active,
		"firstLevel": firstLevel,
		"nbLevels": nbLevels
	}

static func fromDict(parametersDictionary: Dictionary) -> GardeningRectangle:
	var gardeningRectangle : GardeningRectangle = gardeningRectangleTemplate.instantiate()
	gardeningRectangle.id = parametersDictionary["id"]
	gardeningRectangle.position = str_to_var("Vector2" + parametersDictionary["position"])
	gardeningRectangle.firstLevel = parametersDictionary["firstLevel"]
	gardeningRectangle.nbLevels = parametersDictionary["nbLevels"]
	return gardeningRectangle

func _onButtonPressed() -> void:
	var actualLevel: int = get_parent().actualLevel
	if actualLevel < firstLevel + nbLevels:
		get_parent().get_parent().launchLevel(actualLevel)
	else :
		print("no more levels !")
