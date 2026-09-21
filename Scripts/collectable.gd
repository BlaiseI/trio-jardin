class_name Collectable
extends Block

static var collectablePreload = preload("res://Scenes/block_collectable.tscn")
static var collectablesInfo = []
static var level:Level
static var collectables: Array = []

static func clear() -> void:
	collectablesInfo = []

const collectablesTextures = {
	"carrot" : preload("res://art/Finished/collectables/carrot.png")
}

var type: String = "null"

func _ready() -> void:
	if(!level):
		level = get_parent().get_parent()
	$CenterContainer/Control/Sprite2D.texture = collectablesTextures[type]
	doesMatch = false
	moveable = true
	deleteable = false
	return

static func checkPosInLastRow() -> void:
	for collectable : Collectable in collectables:
		var inLastRow = true
		var gridPos = level.grid.getTilePositionFromCoords(collectable.position)
		for i in range(gridPos.x +1, level.grid.height):
			if Vector2(i, gridPos.y) not in level.grid.emptyTiles:
				inLastRow = false
				break
		if(inLastRow):
			collectable.deleteable = true
			level.grid.toTreat.append(gridPos)
			level.collected(collectable.type)
	return

func shrink() -> Signal:
	Collectable.collectables.erase(self)
	var tween:Tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, 30), .3)
	tween.tween_property(self, "scale", Vector2(.1,.1), .1)
	return tween.finished

static func createCollectable(type: String) -> Collectable:
	var collectable : Collectable = collectablePreload.instantiate()
	collectable.type = type
	collectables.append(collectable)
	return collectable

static func init(grid:Grid) -> void:
	for collectableInfo in collectablesInfo:
		var collectable : Collectable = createCollectable(collectableInfo[1])
		grid.replaceBlock(collectableInfo[0], collectable)

func _process(delta: float) -> void:
	pass
