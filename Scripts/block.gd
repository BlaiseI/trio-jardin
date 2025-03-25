class_name Block
extends Node2D

static var blocks = [
	"res://Scenes/block_chardon.tscn",
	"res://Scenes/block_chenille.tscn",
	"res://Scenes/block_ortie.tscn",
	"res://Scenes/block_egopode.tscn"
]

static var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@export var blockType: String
var partOfMatch: bool = false

func move(coords: Vector2) -> Signal:
	var tween = create_tween()
	tween.tween_property(self, "position", coords, .3)
	return tween.finished
	
func shrink() -> Signal:
	var tween:Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(.1,.1), .2)
	return tween.finished

func spawn() -> Signal:
	self.scale = Vector2(0.1,0.1)
	var tween:Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), .2)
	return tween.finished
	
static func createRandomBlock() -> Block:
	return load(blocks[rng.randi_range(0, blocks.size()-1)]).instantiate()
	
