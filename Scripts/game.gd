extends Node2D

const levelSelectorTemplate = preload("res://Scenes/LevelSelector.tscn")
const levelTemplate = preload("res://Scenes/level_scene.tscn")
const hudLevelTemplate = preload("res://Scenes/HUDLevel.tscn")


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
	level.name = "level"
	var hudLevel = hudLevelTemplate.instantiate()
	hudLevel.set_script(load("res://Scripts/hudLevel.gd"))
	hudLevel.level = level

	hudLevel.name = "hudLevel"
	$HUD.add_child(hudLevel)
	var carrotButton = $"HUD/hudLevel/CarrotButton"
	var carrotButtonFunc = $"HUD/hudLevel"._on_carrot_button_pressed
	carrotButton.pressed.connect(carrotButtonFunc.bind(carrotButton))
	add_child(level)
	$levelPanel.queue_free()
	levelSelector.visible = false

func levelFinished(levelNumber: int, succeeded: bool) -> void:
	$"HUD/hudLevel".queue_free()
	level.queue_free()
	if succeeded and levelNumber == levelSelector.actualLevel:
		levelSelector.actualLevel += 1
		levelSelector.update()
	levelSelector.visible = true
	get_tree().paused = false
