class_name Lierre
extends Block

static var lierresInfo = []

func clear() -> void:
	lierresInfo = []

const lierrePreload = preload("res://Scenes/block_lierre.tscn")
const lierreTextures = [
	preload("res://art/Finished/obstacles/lierre1.png"),
	preload("res://art/Finished/obstacles/lierre2.png"),
	preload("res://art/Finished/obstacles/lierre3.png")
]

var triggered = false
var layers = 3

func _ready() -> void:
	$CenterContainer/Control/Sprite2D.texture = lierreTextures[layers-1]
	hasTrigger = true
	doesMatch = false
	moveable = false
	if layers > 1:
		nextBlock = lierrePreload.instantiate()
		nextBlock.layers = layers - 1
		nextBlock.position = position

func trigger(gridPos: Vector2, grid: Grid, toDelete:Array) -> void:
	if triggered:
		return
	triggered = true
	grid.deleteTile(gridPos, toDelete, false)
	if layers > 1:
		var lierreIndex = lierresInfo.find([gridPos,layers])
		lierresInfo[lierreIndex][1] -= 1
	else:
		lierresInfo.erase([gridPos,layers])

static func init(grid:Grid) -> void:
	for lierreInfo in lierresInfo:
		var lierre : Lierre = lierrePreload.instantiate()
		lierre.layers = lierreInfo[1]
		grid.replaceBlock(lierreInfo[0], lierre)

static func endOfTurn(level: Level) -> void:
	var nbLierre : int = 0
	for lierreInfo in lierresInfo:
		nbLierre += level.grid.grid[lierreInfo[0].x][lierreInfo[0].y].layers
	if(level.ConditionType1 == "lierre"):
		level.numberForCondition1 = nbLierre
	if(level.ConditionType2 == "lierre"):
		level.numberForCondition2 = nbLierre
	level.updateNumberConditions(0,0)

func _process(delta: float) -> void:
	pass
