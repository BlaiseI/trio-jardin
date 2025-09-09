class_name LevelPanel
extends Control

var levelButtonTemplate = preload("res://Scenes/LevelButton.tscn")

var actualLevel: int
var firstLevel: int
var nbLevels: int
var offset: Vector2 = Vector2(15, 20)

func _ready() -> void:
	print(self.z_index)
	for i in range(nbLevels):
		var levelButton = levelButtonTemplate.instantiate()
		levelButton.position = offset + Vector2((i%2)*120, (i/2)*70)
		print(i, Vector2((i%2)*40, (i%2)*60))
		levelButton.actualLevel = actualLevel
		levelButton.correspondingLevel = firstLevel + i
		levelButton.pressedSignal.connect($"../../..".launchLevel)
		add_child(levelButton)

func spawn() -> Signal:
	self.scale = Vector2(0.1,0.1)
	var tween:Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), .2)
	return tween.finished
