class_name Level
extends Container

@onready var grid:Grid = $"../grid"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid.height = 8
	grid.width = 8
	grid.emptyTiles = []
	grid.emptyTiles.append(Vector2(3,4))
	grid.emptyTiles.append(Vector2(4,3))
	grid.nbCarrots = 2
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
