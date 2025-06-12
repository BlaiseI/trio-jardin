extends Node2D

const levelSelectorTemplate = preload("res://Scenes/LevelSelector.tscn")
const levelTemplate = preload("res://Scenes/level_scene.tscn")

var levelSelector: LevelSelector
var level: Level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	levelSelector = levelSelectorTemplate.instantiate()
	add_child(levelSelector)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func launchLevel(levelNumber: int) -> void:
	level = levelTemplate.instantiate()
	level.setLevelName(str(levelNumber))
	add_child(level)
	levelSelector.visible = false
