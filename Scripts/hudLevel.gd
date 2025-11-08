class_name HUDLevel
extends CanvasLayer

var conditionsNodes: Array
var level:Level
var conditionPreload = preload("res://Scenes/condition.tscn")
var conditionTexturePaths: Dictionary = {
	"chardon": "res://art/Finished/weeds/chardon60.png",
 	"chenille": "res://art/Finished/weeds/chenille60.png",
	"egopode": "res://art/Finished/weeds/egopode60.png",
	"ortie": "res://art/Finished/weeds/ortie60.png",
	"pissenlit": "res://art/Finished/weeds/pissenlit.png",
	"morille": "res://art/Finished/weeds/morille.png",
	"web": "res://art/Finished/obstacles/Web.png",
	"firecracker": "res://art/Finished/power-ups/firecracker1.png",
	"mouton": "res://art/Finished/power-ups/mouton1.png",
	"ronce": "res://art/Finished/obstacles/ronceMoche.png",
	"lierre": "res://art/Finished/obstacles/lierreMoche.png"
}

func _on_carrot_button_pressed() -> void:
	level.carrotPressed()

func updateNbCarrots(nbCarrots: int) -> void:
	$"NumberOfCarrots".text = str(nbCarrots)

func updateNbCondition(condition: Array, index: int) -> void:
	conditionsNodes[index].find_child("ConditionNumber").text = str(condition[1])

func updateNbMovesLeft(nbMovesLeft: int) -> void:
	$"NumberMovesLeft".text = str(nbMovesLeft)

func updateGameOverMessage(message: String) -> void:
	$"GameOverMsg".text = message

func blackenBackground() -> void:
	$"..".changeBrightness("/root/Game/level/TopBannerBackground", 0.5)
	$"..".changeBrightness("/root/Game/level/GridBackground", 0.5)

func unBlackenBackground() -> void:
	$"..".changeBrightness("/root/Game/level/TopBannerBackground", 1)
	$"..".changeBrightness("/root/Game/level/GridBackground", 1)

func createConditions(conditions: Array) -> void:
	conditionsNodes = []
	for i:int in range(conditions.size()):
		var condition:Node = conditionPreload.instantiate()
		condition.find_child("ConditionTexture").texture = load(conditionTexturePaths[conditions[i][0]])
		condition.find_child("ConditionNumber").text = str(conditions[i][1])
		condition.position = Vector2(392,12)
		if not i%2:
			condition.position.x += 88
			if i==conditions.size()-1:
				condition.position.x -= 40
		if i/2:
			condition.position.y += 68
		elif conditions.size() < 3:
			condition.position.y += 34
		conditionsNodes.append(condition)
		add_child(condition)
	pass
