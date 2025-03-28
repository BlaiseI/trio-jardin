class_name Level
extends Container

enum{waitInput, treatMove, waitPowerUpInput, treatPowerUp}
var state
enum{carrot}
var currentPowerUp

@onready var grid:Grid = $"../grid"
@onready var hud:HUD = $"../HUD"

var slideOngoing: bool = false
var slideBeginPos: Vector2
var slideBeginCoords: Vector2

var nbCarrots: int = 2
var carrotButtonReleased: bool = false
var blockTypeCondition1: String = "Chardon"
var numberForCondition1: int = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid.height = 8
	grid.width = 8
	grid.emptyTiles = []
	grid.emptyTiles.append(Vector2(3,4))
	grid.emptyTiles.append(Vector2(4,3))
	hud.updateNbCarrots(nbCarrots)
	hud.updateNbCondition1(numberForCondition1)
	grid.initGrid()
	state = waitInput

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == waitInput:
		getSlideInput()
	elif state == waitPowerUpInput:
		getPowerUpInput()

func getSlideInput() -> void:
	if Input.is_action_just_pressed("ui_touch"):
		var touchCoords: Vector2 = get_global_mouse_position()
		if grid.isInGrid(touchCoords):
			var tileTouched: Vector2 = grid.getTilePositionFromCoords(touchCoords)
			if !grid.isTileEmpty(tileTouched):
				slideOngoing = true
				slideBeginCoords = touchCoords
				slideBeginPos =  tileTouched
	if Input.is_action_just_released("ui_touch"):
		if slideOngoing:
			var touchCoords: Vector2 = get_global_mouse_position()
			if grid.isInGrid(touchCoords):
				var slideDirection: Vector2 = Utils.getSlideDirection(slideBeginCoords, touchCoords)
				var tileTouched: Vector2 = Vector2(slideBeginPos.x + slideDirection.x, slideBeginPos.y + slideDirection.y)
				if !grid.isTileEmpty(tileTouched):
					state = treatMove
					await treatSlide(tileTouched)
					state = waitInput
		slideOngoing = false

func treatSlide(slideEndPos: Vector2) -> void:
	if slideBeginPos == slideEndPos:
		return
	
	await grid.swapBlocks(slideBeginPos, slideEndPos)
	if grid.getMatchesOnGrid():
		await treatMatches()
	else:
		await grid.swapBlocks(slideBeginPos, slideEndPos)

func treatMatches() -> void:
	while grid.getMatchesOnGrid():
		await deleteMatches()
		await grid.getBlocksDown()
		await grid.fillEmptyBlocks()
	return

func deleteMatches() -> void:
	var conditionDictionary: Dictionary = {blockTypeCondition1: 0}
	conditionDictionary = await grid.deleteMatches(conditionDictionary)
	numberForCondition1 -= conditionDictionary[blockTypeCondition1]
	if numberForCondition1 <= 0:
		print("Victory !")
		numberForCondition1 = 0
	hud.updateNbCondition1(numberForCondition1)

func getPowerUpInput() -> void:
	if carrotButtonReleased and Input.is_action_just_pressed("ui_touch"):
		var touchCoords: Vector2 = get_global_mouse_position()
		if grid.isInGrid(touchCoords):
			var tileTouched: Vector2 = grid.getTilePositionFromCoords(touchCoords)
			if !grid.isTileEmpty(tileTouched):
				state = treatPowerUp
				await grid.deleteTile(tileTouched)
				nbCarrots -= 1
				hud.unBlackenBackground()
				hud.updateNbCarrots(nbCarrots)
				await grid.getBlocksDown()
				await grid.fillEmptyBlocks()
				await treatMatches()
				state = waitInput
		hud.unBlackenBackground()
		state = waitInput
		carrotButtonReleased = false
	elif Input.is_action_just_released("ui_touch"):
		carrotButtonReleased = true

func carrotPressed() -> void:
	if state != waitInput:
		return
	if nbCarrots > 0:
		state = waitPowerUpInput
		currentPowerUp = carrot
		hud.blackenBackground()
	
