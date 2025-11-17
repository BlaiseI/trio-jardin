class_name Lierre
extends Block

static var lierresInfo = []
static var lierres = []

static func clear() -> void:
	lierresInfo = []
	lierres = []

const lierrePreload = preload("res://Scenes/block_lierre.tscn")
const lierreTextures = [
	preload("res://art/Finished/obstacles/lierre1.png"),
	preload("res://art/Finished/obstacles/lierre2.png"),
	preload("res://art/Finished/obstacles/lierre3.png")
]

var triggered = false
var layers = 3

func _ready() -> void:
	lierres.append(self)
	$CenterContainer/Control/Sprite2D.texture = lierreTextures[layers-1]
	hasTrigger = true
	doesMatch = false
	moveable = false
	if layers > 1:
		nextBlock = lierrePreload.instantiate()
		nextBlock.layers = layers - 1
		nextBlock.position = position

func trigger(gridPos: Vector2, grid: Grid, funcsToWait:Array) -> void:
	if triggered:
		return
	triggered = true
	funcsToWait.append(gridPos)
	grid.deleteTile(gridPos, funcsToWait, false)
	if layers > 1:
		var lierreIndex = lierresInfo.find([gridPos,layers])
		lierresInfo[lierreIndex][1] -= 1
	else:
		lierresInfo.erase([gridPos,layers])
	funcsToWait.erase(gridPos)
	return

static func init(grid:Grid) -> void:
	for lierreInfo in lierresInfo:
		var lierre : Lierre = lierrePreload.instantiate()
		lierre.layers = lierreInfo[1]
		grid.replaceBlock(lierreInfo[0], lierre)

static func endOfTurn(level: Level) -> void:
	for lierre in lierres:
		lierre.triggered = false

func _process(delta: float) -> void:
	pass
