class_name Ronce
extends Block

static var triggered = false
static var roncesPositions = []

func clear() -> void:
	triggered = false
	roncesPositions = []

const roncePreload = preload("res://Scenes/block_ronce.tscn")

var blockTriggered = false

func _ready() -> void:
	hasTrigger = true
	doesMatch = false
	moveable = false

func trigger(gridPos: Vector2, grid: Grid, toDelete:Array) -> void:
	if blockTriggered:
		return
	blockTriggered = true
	triggered = true
	grid.deleteTile(gridPos, toDelete, false)
	roncesPositions.erase(gridPos)

static func endOfTurn(level: Level) -> void:
	var grid:Grid = level.grid
	if (!triggered and roncesPositions.size() > 0):
		var freeSpot = Vector2(-1,-1)
		while (freeSpot == Vector2(-1,-1)):
			var gridPos: Vector2 = roncesPositions[randi() % roncesPositions.size()]
			var neighbours: Array = []
			if(gridPos.x > 0 and Vector2(gridPos.x -1, gridPos.y) not in grid.emptyTiles and Vector2(gridPos.x -1, gridPos.y) not in roncesPositions):
				neighbours.append(Vector2(gridPos.x -1, gridPos.y))
			if(gridPos.x < grid.height-1 and Vector2(gridPos.x +1, gridPos.y) not in grid.emptyTiles and Vector2(gridPos.x +1, gridPos.y) not in roncesPositions):
				neighbours.append(Vector2(gridPos.x +1, gridPos.y))
			if(gridPos.y > 0 and Vector2(gridPos.x, gridPos.y-1) not in grid.emptyTiles and Vector2(gridPos.x, gridPos.y-1) not in roncesPositions):
				neighbours.append(Vector2(gridPos.x, gridPos.y-1))
			if(gridPos.y < grid.width-1 and Vector2(gridPos.x, gridPos.y+1) not in grid.emptyTiles and Vector2(gridPos.x, gridPos.y+1) not in roncesPositions):
				neighbours.append(Vector2(gridPos.x, gridPos.y+1))
			if neighbours.size() > 1:
				freeSpot = neighbours[randi() % neighbours.size()]
		grid.replaceBlock(freeSpot, roncePreload.instantiate())
		grid.grid[freeSpot.x][freeSpot.y].spawn()
		roncesPositions.append(freeSpot)
	if(level.ConditionType1 == "ronce"):
		level.numberForCondition1 = roncesPositions.size()
	if(level.ConditionType2 == "ronce"):
		level.numberForCondition2 = roncesPositions.size()
	level.updateNumberConditions(0,0)
	triggered = false

static func init(grid:Grid) -> void:
	for roncePos in roncesPositions:
		var ronce : Ronce = roncePreload.instantiate()
		grid.replaceBlock(roncePos, ronce)

func _process(delta: float) -> void:
	pass
