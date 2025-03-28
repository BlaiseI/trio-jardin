class_name HUD
extends CanvasLayer

@onready var level:Level = $"../LevelCodeContainer"

func _on_carrot_button_pressed() -> void:
	level.carrotPressed()

func blackenBackground() -> void:
	$"../TopBannerBackground".modulate.r = 0.5
	$"../TopBannerBackground".modulate.g = 0.5
	$"../TopBannerBackground".modulate.b = 0.5
	$"../GridBackground".modulate.r = 0.5
	$"../GridBackground".modulate.g = 0.5
	$"../GridBackground".modulate.b = 0.5
	
func unBlackenBackground() -> void:
	$"../TopBannerBackground".modulate.r = 1
	$"../TopBannerBackground".modulate.g = 1
	$"../TopBannerBackground".modulate.b = 1
	$"../GridBackground".modulate.r = 1
	$"../GridBackground".modulate.g = 1
	$"../GridBackground".modulate.b = 1

func updateNbCarrots(nbCarrots: int) -> void:
	$"NumberOfCarrots".text = str(nbCarrots)
	
