class_name Lierre
extends Block

static var lierrePositions = []
static var lierrePreload = preload("res://Scenes/block_lierre.tscn")

var triggered = false

func _ready() -> void:
	hasTrigger = true
	doesMatch = false
	moveable = false

func trigger(gridPos: Vector2, grid: Grid, toDelete:Array) -> void:
	if triggered:
		return
	triggered = true
	grid.deleteTile(gridPos, toDelete, false)
	lierrePositions.erase(gridPos)

static func init(grid:Grid) -> void:
	for lierrePos in lierrePositions:
		var lierre : Lierre = lierrePreload.instantiate()
		grid.replaceBlock(lierrePos, lierre)

static func endOfTurn(level: Level) -> void:

	if(level.ConditionType1 == "lierre"):
		level.numberForCondition1 = lierrePositions.size()
	if(level.ConditionType2 == "lierre"):
		level.numberForCondition2 = lierrePositions.size()
	level.updateNumberConditions(0,0)

func _process(delta: float) -> void:
	pass
