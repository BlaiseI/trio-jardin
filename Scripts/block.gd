extends Node2D

@export var blockType: String
var partOfMatch: bool = false

func move(coords: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", coords, .5)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
