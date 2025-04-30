extends Node2D

var nbGardeningRectangle: int = 6
var gardeningRectangles: PackedVector2Array = PackedVector2Array([
		Vector2(60,200),
		Vector2(352,176),
		Vector2(84,400),
		Vector2(380,392),
		Vector2(72,612),
		Vector2(368,624)
	])
var gardeningRectTemplate:PackedScene = preload("res://Scenes/gardeningRect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for gardeningRectangleCoords: Vector2 in gardeningRectangles:
		var gardeningRect: Node2D = gardeningRectTemplate.instantiate()
		gardeningRect.position = gardeningRectangleCoords
		add_child(gardeningRect)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_released("ui_touch"):
	#	var touchCoords: Vector2 = get_global_mouse_position()
	pass
