class_name Ronce
extends Block

static var triggered = false
static var roncesPositions = []
static var roncePreload = preload("res://Scenes/block_ronce.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hasTrigger = true
	doesMatch = false
	moveable = false

func trigger(toTrigger: Array, alreadyTriggered: Array, toDelete:Array, gridPos: Vector2) -> void:
	triggered = true
	get_parent().uniqueAdd(toDelete, gridPos)
	roncesPositions.erase(gridPos)

static func endOfTurn(level: Level) -> void:
	var grid:Grid = level.grid
	if (!triggered and roncesPositions.size() > 0):
		print(roncesPositions)
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
		roncesPositions.append(freeSpot)
	if(level.ConditionType1 == "ronce"):
		level.numberForCondition1 = roncesPositions.size()
	if(level.ConditionType2 == "ronce"):
		level.numberForCondition2 = roncesPositions.size()
	level.updateNumberConditions(0,0)
	triggered = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
