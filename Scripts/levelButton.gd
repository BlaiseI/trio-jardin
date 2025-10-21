extends Node2D

var actualLevel: int
var correspondingLevel: int
signal pressedSignal

func _ready() -> void:
	$Label.text = str(correspondingLevel)
	$Border.modulate.a = 0.7
	if(correspondingLevel < actualLevel):
		$Border.modulate.r = 0
		$Border.modulate.b = 0
	if(correspondingLevel == actualLevel):
		$Border.modulate.r = 0
		$Border.modulate.g = 0
	if(correspondingLevel > actualLevel):
		$Border.modulate.g = 0
		$Border.modulate.b = 0
		$Button.disabled = true

func _on_button_pressed() -> void:
	print(correspondingLevel)
	pressedSignal.emit(correspondingLevel)
