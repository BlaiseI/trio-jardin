class_name LevelPanel
extends Control

var levelButtonTemplate = preload("res://Scenes/LevelButton.tscn")

var actualLevel: int
var firstLevel: int
var nbLevels: int
var offset: Vector2 = Vector2(36, 36)

func _ready() -> void:
	$CloseButton.pressed.connect($"../../".closePanel)
	$CropButton.pressed.connect($"../../".changePanel)
	$CropButton.disabled = actualLevel < firstLevel+nbLevels
	for i in range(nbLevels):
		var levelButton = levelButtonTemplate.instantiate()
		levelButton.global_position = offset + Vector2((i%3)*145, (i/3)*85)
		levelButton.actualLevel = actualLevel
		levelButton.correspondingLevel = firstLevel + i
		levelButton.pressedSignal.connect($"../../../..".launchLevel)
		add_child(levelButton)

func spawn() -> Signal:
	self.scale = Vector2(0.1,0.1)
	var tween:Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), .3)
	return tween.finished
