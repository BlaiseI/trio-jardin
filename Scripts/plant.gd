class_name Plant
extends TextureButton

const plantTextures = {
	"carrot" : preload("res://art/Finished/gathering/carrot.png")
}

var type:String = "null"
var number:int = 0

func _ready() -> void:
	texture_normal = plantTextures[type]
	$Number.text = str(number)

func _process(delta: float) -> void:
	return

func _onButtonPressed() -> void:
	$"../".selectPlant(type)

func setNumber(newNumber: int) -> void:
	number = newNumber
	$Number.text = str(number)
