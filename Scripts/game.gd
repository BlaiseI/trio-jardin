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

func levelFinished(levelNumber: int, succeeded: bool) -> void:
	level.queue_free()
	if succeeded and levelNumber == levelSelector.actualLevel:
		print("here")
		levelSelector.actualLevel += 1
		levelSelector.update()
	levelSelector.visible = true
	get_tree().paused = false
