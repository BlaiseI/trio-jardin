extends CanvasLayer

@onready var level:Level = $"../LevelCodeContainer"

func _on_carrot_button_pressed() -> void:
	
	var grid: Grid = $"../grid"
	if grid.state == grid.checkMove:
		$"../TopBannerBackground".modulate.r = 0.5
		$"../TopBannerBackground".modulate.g = 0.5
		$"../TopBannerBackground".modulate.b = 0.5
		$"../GridBackground".modulate.r = 0.5
		$"../GridBackground".modulate.g = 0.5
		$"../GridBackground".modulate.b = 0.5
		grid.state = grid.carrot
	
func carrotReleased(nbCarrots: int) -> void:
	$"../TopBannerBackground".modulate.r = 1
	$"../TopBannerBackground".modulate.g = 1
	$"../TopBannerBackground".modulate.b = 1
	$"../GridBackground".modulate.r = 1
	$"../GridBackground".modulate.g = 1
	$"../GridBackground".modulate.b = 1
	$"NumberOfCarrots".text = str(nbCarrots)
	#$"NumberOfCarrots".text = numberOfCarrots
	
