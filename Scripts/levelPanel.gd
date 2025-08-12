class_name LevelPanel
extends Node2D

var levelButtonTemplate = preload("res://Scenes/LevelButton.tscn")

var actualLevel: int
var firstLevel: int
var nbLevels: int
var offset: Vector2 = Vector2(20, 40)

func _ready() -> void:
	for i in range(nbLevels):
		var levelButton = levelButtonTemplate.instantiate()
		levelButton.position = position + offset + Vector2((i%2)*40, (i%2)*60)
		levelButton.actualLevel = actualLevel
		levelButton.correspondingLevel = firstLevel + i
		levelButton.pressedSignal.connect($"../../..".launchLevel)
		add_child(levelButton)
