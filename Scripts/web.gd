class_name Web
extends Block

func _ready() -> void:
	moveable = false
	nextBlock = Block.createRandomBlock()
	nextBlock.position = position
	blockType = nextBlock.blockType
	print(blockType)
	$"CenterContainer/Control/Sprite2D".texture = nextBlock.find_child("Sprite2D").texture
	pass

func shrink() -> Signal:
	var tween:Tween = create_tween()
	tween.tween_property($"CenterContainer/Control/Web", "scale", Vector2(.1,.1), .2)
	return tween.finished
