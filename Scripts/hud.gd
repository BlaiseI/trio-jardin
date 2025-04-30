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

func updateNbCondition1(nbCondition1: int) -> void:
	$"NumberForCondition1".text = str(nbCondition1)

func updateNbCondition2(nbCondition2: int) -> void:
	$"NumberForCondition2".text = str(nbCondition2)

func updateNbMovesLeft(nbMovesLeft: int) -> void:
	$"NumberMovesLeft".text = str(nbMovesLeft)

func updateGameOverMessage(message: String) -> void:
	$"GameOverMsg".text = message

func setCondition1(conditionType1: String) -> void:
	if conditionType1 == "null":
		$"../TopBannerBackground/WinningConditions/Condition1".texture = null
	else:
		var texturePath : String = "res://art/Finished/weeds/" + conditionType1.to_lower() + "60.png"
		$"../TopBannerBackground/WinningConditions/Condition1".texture = load(texturePath)

func setCondition2(conditionType2: String) -> void:
	if conditionType2 == "null":
		$"../TopBannerBackground/WinningConditions/Condition2".texture = null
	else:
		var texturePath : String = "res://art/Finished/weeds/" + conditionType2.to_lower() + "60.png"
		$"../TopBannerBackground/WinningConditions/Condition2".texture = load(texturePath)
