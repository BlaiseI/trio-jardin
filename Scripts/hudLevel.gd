class_name HUDLevel
extends CanvasLayer

var level:Level
var conditionTexturePaths: Dictionary = {"chardon": "res://art/Finished/weeds/chardon60.png",
 	"chenille": "res://art/Finished/weeds/chenille60.png",
	"egopode": "res://art/Finished/weeds/egopode60.png",
	"ortie": "res://art/Finished/weeds/ortie60.png",
	"pissenlit": "res://art/Finished/weeds/pissenlit.png",
	"morille": "res://art/Finished/weeds/morille.png",
	"web": "res://art/Finished/obstacles/Web.png",
	"firecracker": "res://art/Finished/power-ups/firecracker1.png",
	"ronce": "res://art/Finished/obstacles/ronceMoche.png"
}

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
		$"WinningConditions/Condition1".texture = null
	else:
		$"WinningConditions/Condition1".texture = load(conditionTexturePaths[conditionType1])

func setCondition2(conditionType2: String) -> void:
	if conditionType2 == "null":
		$"WinningConditions/Condition2".texture = null
	else:
		$"WinningConditions/Condition2".texture = load(conditionTexturePaths[conditionType2])

func blackenBackground() -> void:
	$"..".changeBrightness("/root/Game/level/TopBannerBackground", 0.5)
	$"..".changeBrightness("/root/Game/level/GridBackground", 0.5)

func unBlackenBackground() -> void:
	$"..".changeBrightness("/root/Game/level/TopBannerBackground", 1)
	$"..".changeBrightness("/root/Game/level/GridBackground", 1)
