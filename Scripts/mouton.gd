class_name Mouton
extends Block

var triggerStarted:bool = false
var triggerFinished:bool = false

func _ready() -> void:
	hasTrigger = true
	doesMatch = false

func trigger(gridPos: Vector2, grid:Grid, funcsToWait:Array) -> void:
	if triggerStarted:
		while(not triggerFinished):
			await get_tree().create_timer(0.02).timeout
		return
	triggerStarted = true
	funcsToWait.append(gridPos)
	await get_tree().create_timer(0.1).timeout
	var directions:Array = ["north", "south", "east", "west"]
	var direction = directions[randi() % directions.size()]
	if direction == "north":
		for i in range(gridPos.x-1, -1, -1):
			await self.move(grid.utils.getTileCoords(Vector2(i, gridPos.y), grid))
			grid.deleteTile(Vector2(i, gridPos.y),funcsToWait)
	if direction == "south":
		for i in range(gridPos.x+1, grid.height):
			await self.move(grid.utils.getTileCoords(Vector2(i, gridPos.y), grid))
			grid.deleteTile(Vector2(i, gridPos.y),funcsToWait)
	if direction == "east":
		for j in range(gridPos.y+1, grid.width):
			await self.move(grid.utils.getTileCoords(Vector2(gridPos.x, j), grid))
			grid.deleteTile(Vector2(gridPos.x, j),funcsToWait)
	if direction == "west":
		for j in range(gridPos.y-1, -1, -1):
			await self.move(grid.utils.getTileCoords(Vector2(gridPos.x, j), grid))
			grid.deleteTile(Vector2(gridPos.x, j),funcsToWait)
	triggerFinished = true
	grid.deleteTile(gridPos, funcsToWait)
	funcsToWait.erase(gridPos)

	return
