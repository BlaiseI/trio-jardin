class_name Firecracker
extends Block


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hasTrigger = true
	doesMatch = false

func trigger(toTrigger: Array, alreadyTriggered: Array, toDelete:Array, gridPos: Vector2) -> void:
	var grid: Grid = get_parent()
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
	grid.uniqueAdd(toDelete, gridPos)
	grid.uniqueAdd(toTrigger, gridPos)
	grid.uniqueAdd(toDelete, randomNeighbour)
	grid.uniqueAdd(toTrigger, randomNeighbour)
