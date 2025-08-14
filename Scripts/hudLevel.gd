class_name HUDLevel
extends CanvasLayer

var level:Level

func _on_carrot_button_pressed() -> void:
	level.carrotPressed()

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

func blackenBackground() -> void:
	$"..".changeBrightness("../../level/TopBannerBackground", 0.5)
	$"..".changeBrightness("../../level/GridBackground", 0.5)

func unBblackenBackground() -> void:
	$"..".changeBrightness("../../level/TopBannerBackground", 1)
	$"..".changeBrightness("../../level/GridBackgroud", 1)
