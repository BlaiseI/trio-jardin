class_name PowerUp
extends TextureButton

var waitClick: bool
var type: String
var numberLeft: int

func carrot(level: Level, pos: Vector2) -> void:
	level.grid.toTreat.append(pos)
	numberLeft -= 1
	level.hud.updateNbPowerUp(self)
	await level.treatMatches(false)
	return

func fraise(level: Level) -> void:
	numberLeft -= 1
	level.numberMovesLeft += 5
	level.hud.updateNbPowerUp(self)
	level.hud.updateNbMovesLeft(level.numberMovesLeft)
	return

func _on_pressed() -> void:
	var level:Level = get_tree().root.find_child("level", true, false)
	level.powerUpPressed(self)
