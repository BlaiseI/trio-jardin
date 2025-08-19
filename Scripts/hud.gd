class_name HUD
extends CanvasLayer

var level:Level

func changeBrightness(element: String, scale: float) -> void:
	print(get_node(element))
	var texture = get_node(element)
	texture.modulate.r = scale
	texture.modulate.g = scale
	texture.modulate.b = scale
