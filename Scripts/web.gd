class_name Web
extends Node2D

func shrink() -> Signal:
	var tween:Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(.1,.1), .2)
	return tween.finished
