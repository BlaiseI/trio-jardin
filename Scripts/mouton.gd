class_name Mouton
extends Block

var triggered:bool = false

func _ready() -> void:
	hasTrigger = true
	doesMatch = false

func trigger(gridPos: Vector2, grid:Grid, toDelete:Array) -> Array:
	var animSignals = []
	if triggered:
		return animSignals
	triggered = true
	# get_tree().create_timer(0.1).timeout
	var directions:Array = ["north", "south", "east", "west"]
	var direction = directions[randi() % directions.size()]
	if direction == "north":
		for i in range(gridPos.x-1, -1, -1):
			animSignals.append(await self.move(grid.utils.getTileCoords(Vector2(i, gridPos.y), grid)))
			grid.toTreat.append(Vector2(i, gridPos.y))
	if direction == "south":
		for i in range(gridPos.x+1, grid.height):
			animSignals.append(await self.move(grid.utils.getTileCoords(Vector2(i, gridPos.y), grid)))
			grid.toTreat.append(Vector2(i, gridPos.y))
	if direction == "east":
		for j in range(gridPos.y+1, grid.width):
			animSignals.append(await self.move(grid.utils.getTileCoords(Vector2(gridPos.x, j), grid)))
			grid.toTreat.append(Vector2(gridPos.x, j))
	if direction == "west":
		for j in range(gridPos.y-1, -1, -1):
			animSignals.append(await self.move(grid.utils.getTileCoords(Vector2(gridPos.x, j), grid)))
			grid.toTreat.append(Vector2(gridPos.x, j))
	animSignals.append(await grid.deleteTile(gridPos, toDelete))
	return animSignals
