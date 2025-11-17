class_name Collectable
extends Block

static var collectablePreload = preload("res://Scenes/block_collectable.tscn")
static var collectablesInfo = []
static var collectables = []
static var level:Level

static func clear() -> void:
	collectablesInfo = []
	collectables = []

const collectablesTextures = {
	"carrot" : preload("res://art/Finished/collectables/carrot.png")
}

var type: String = "null"

func _ready() -> void:
	$CenterContainer/Control/Sprite2D.texture = collectablesTextures[type]
	doesMatch = false
	moveable = true
	deleteable = false
	collectables.append(self)

func move(coords: Vector2) -> Signal:
	var _return = super(coords)
	var gridPos = level.grid.getTilePositionFromCoords(coords)
	for i in range(gridPos.x +1, level.grid.height):
		if Vector2(i, gridPos.y) not in level.grid.emptyTiles:
			return _return
	deleteable = true
	level.grid.toTreat.append(gridPos)
	level.collected(type)
	return _return

func shrink() -> Signal:
	var tween:Tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, 30), .3)
	tween.tween_property(self, "scale", Vector2(.1,.1), .1)
	return tween.finished

static func init(grid:Grid) -> void:
	level = grid.get_parent()
	for collectableInfo in collectablesInfo:
		var collectable : Collectable = collectablePreload.instantiate()
		collectable.type = collectableInfo[1]
		grid.replaceBlock(collectableInfo[0], collectable)

func _process(delta: float) -> void:
	pass
