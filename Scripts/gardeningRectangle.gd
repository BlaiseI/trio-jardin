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
	$"Button".modulate.a = 0
	if !active:
		blacken()
		$"Button".disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func blacken() -> void:
	$"background".modulate.r = 0.5
	$"background".modulate.g = 0.5
	$"background".modulate.b = 0.5

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
	gardeningRectangle.active = parametersDictionary["active"]
	gardeningRectangle.firstLevel = parametersDictionary["firstLevel"]
	gardeningRectangle.nbLevels = parametersDictionary["nbLevels"]
	return gardeningRectangle

func _onButtonPressed() -> void:
	var actualLevel: int = get_parent().actualLevel
	get_parent().get_parent().launchLevel(actualLevel)
	print("Button pressed")
