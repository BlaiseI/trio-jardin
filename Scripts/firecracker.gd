class_name Firecracker
extends Block

var triggered:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hasTrigger = true
	doesMatch = false

func trigger(gridPos: Vector2, grid: Grid, toDelete:Array) -> Array:
	var animSignals: Array = []
	if triggered:
		return animSignals
	triggered = true
	var neighbours = []
	if(gridPos.x > 0 and Vector2(gridPos.x -1, gridPos.y) not in grid.emptyTiles):
		neighbours.append(Vector2(gridPos.x -1, gridPos.y))
	if(gridPos.x < grid.height-1 and Vector2(gridPos.x +1, gridPos.y) not in grid.emptyTiles):
		neighbours.append(Vector2(gridPos.x +1, gridPos.y))
	if(gridPos.y > 0 and Vector2(gridPos.x, gridPos.y-1) not in grid.emptyTiles):
		neighbours.append(Vector2(gridPos.x, gridPos.y-1))
	if(gridPos.y < grid.width-1 and Vector2(gridPos.x, gridPos.y+1) not in grid.emptyTiles):
		neighbours.append(Vector2(gridPos.x, gridPos.y+1))
	var randomNeighbour = neighbours[randi() % neighbours.size()]
	animSignals.append(await grid.deleteTile(gridPos, toDelete))
	grid.toTreat.append(randomNeighbour)
	return animSignals
