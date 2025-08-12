extends Node2D

var actualLevel: int
var correspondingLevel: int
signal pressedSignal

func _ready() -> void:
	$Button/Label.text = str(correspondingLevel)
	if(correspondingLevel > actualLevel):
		$Button.disabled = true

func _on_button_pressed() -> void:
	pressedSignal.emit(correspondingLevel)
