class_name Mouton
extends Block

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hasTrigger = true
	doesMatch = false

func trigger(toTrigger: Array, alreadyTriggered: Array, toDelete:Array, gridPos: Vector2) -> void:
	await get_tree().create_timer(0.1).timeout
	var grid: Grid = get_parent()
	var directions:Array = ["north", "south", "east", "west"]
	var direction = directions[randi() % directions.size()]
	grid.uniqueAdd(toDelete, gridPos)
	grid.uniqueAdd(toTrigger, gridPos)
	if direction == "north":
		for i in range(gridPos.x-1, -1, -1):
			await self.move(grid.utils.getTileCoords(Vector2(i, gridPos.y), grid))
			grid.deleteTile(Vector2(i, gridPos.y))
			grid.uniqueAdd(toTrigger, Vector2(i, gridPos.y))
	if direction == "south":
		for i in range(gridPos.x+1, grid.height):
			await self.move(grid.utils.getTileCoords(Vector2(i, gridPos.y), grid))
			grid.deleteTile(Vector2(i, gridPos.y))
			grid.uniqueAdd(toTrigger, Vector2(i, gridPos.y))
	if direction == "east":
		for j in range(gridPos.y+1, grid.width):
			await self.move(grid.utils.getTileCoords(Vector2(gridPos.x, j), grid))
			grid.deleteTile(Vector2(gridPos.x, j))
			grid.uniqueAdd(toTrigger, Vector2(gridPos.x, j))
	if direction == "west":
		for j in range(gridPos.y-1, -1, -1):
			await self.move(grid.utils.getTileCoords(Vector2(gridPos.x, j), grid))
			grid.deleteTile(Vector2(gridPos.x, j))
			grid.uniqueAdd(toTrigger, Vector2(gridPos.x, j))
