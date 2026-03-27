class_name Seed
extends TextureButton

const seedTextures = {
	"carrot" : preload("res://art/Finished/gathering/CarrotSeeds.png")
}

var type:String = "null"
var number:int = 0

func _ready() -> void:
	texture_normal = seedTextures[type]
	$Number.text = str(number)

func _process(delta: float) -> void:
	return

func _onButtonPressed() -> void:
	$"../".plantSeed(type)
	$Number.text = str(number)

func setNumber(newNumber: int) -> void:
	number = newNumber
	$Number.text = str(number)
