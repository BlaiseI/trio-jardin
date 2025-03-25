extends Node2D

@export var blockType: String
var partOfMatch: bool = false

func move(coords: Vector2) -> Signal:
	var tween = create_tween()
	tween.tween_property(self, "position", coords, .3)
	return tween.finished
	
func shrink() -> Signal:
	var tween:Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(.1,.1), .2)
	return tween.finished

func spawn() -> Signal:
	self.scale = Vector2(0.1,0.1)
	var tween:Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), .2)
	return tween.finished
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
