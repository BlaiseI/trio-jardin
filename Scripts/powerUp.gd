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
	pass

func fraise(level: Level) -> void:
	numberLeft -= 1
	level.numberMovesLeft += 5
	level.hud.updateNbPowerUp(self)
	level.hud.updateNbMovesLeft(level.numberMovesLeft)
	pass

func _on_pressed() -> void:
	var level:Level = get_tree().root.find_child("level", true, false)
	level.powerUpPressed(self)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
