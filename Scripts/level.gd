class_name Level
extends Node2D

enum{waitInput, treatMove, waitPowerUpInput, treatPowerUp, gameOver}
var state
enum{carrot}
var currentPowerUp

@onready var grid:Grid = $"grid"
@onready var hud:HUDLevel = $"../HUD/hudLevel"

@export var levelName = "1"

var slideOngoing: bool = false
var slideBeginPos: Vector2
var slideBeginCoords: Vector2

var nbCarrots: int
var carrotButtonReleased: bool = false
var ConditionType1: String
var numberForCondition1: int
var ConditionType2: String
var numberForCondition2: int
var numberMovesLeft: int

func setLevelName(levelName: String) -> void:
	self.levelName = levelName

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	loadParameters("res://levels/level" + levelName + ".json")
	updateParametersInHUD()
	grid.initGrid()
	state = waitInput

func updateParametersInHUD() -> void:
	hud.updateNbCarrots(nbCarrots)
	hud.updateNbCondition1(numberForCondition1)
	hud.updateNbCondition2(numberForCondition2)
	hud.updateNbMovesLeft(numberMovesLeft)
	hud.setCondition1(ConditionType1)
	hud.setCondition2(ConditionType2)

func loadParameters(filePath: String) -> void:
	var saveFile:FileAccess = FileAccess.open(filePath, FileAccess.READ)
	var paramsJSONString = saveFile.get_line()
	var paramsJSON = JSON.new()
	paramsJSON.parse(paramsJSONString)
	var parametersDictionary: Dictionary = paramsJSON.data
	grid.height = parametersDictionary["gridHeight"]
	grid.width = parametersDictionary["gridWidth"]
	grid.emptyTiles = []
	for positionString: String in parametersDictionary["gridEmptyTiles"]:
		var positionVector:Vector2 = str_to_var("Vector2" + positionString)
		grid.emptyTiles.append(positionVector)
	nbCarrots = parametersDictionary["nbCarrots"]
	ConditionType1 = parametersDictionary["ConditionType1"]
	ConditionType2 = parametersDictionary["ConditionType2"]
	numberForCondition1 = parametersDictionary["numberForCondition1"]
	numberForCondition2 = parametersDictionary["numberForCondition2"]
	numberMovesLeft = parametersDictionary["numberMovesLeft"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == waitInput:
		getSlideInput()
	elif state == waitPowerUpInput:
		getPowerUpInput()
	else :
		return

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
		numberMovesLeft -= 1
		hud.updateNbMovesLeft(numberMovesLeft)
		await treatMatches()
	else:
		await grid.swapBlocks(slideBeginPos, slideEndPos)

func treatMatches() -> void:
	while grid.getMatchesOnGrid():
		await deleteMatches()
		await grid.getBlocksDown()
		await grid.fillEmptyBlocks()
	if state == gameOver:
		hud.updateGameOverMessage("Victory !")
		get_tree().paused = true
		await get_tree().create_timer(2).timeout
		get_parent().levelFinished(int(levelName), true)
	elif numberMovesLeft <= 0:
		state = gameOver
		hud.updateGameOverMessage("Defeat !")
		get_tree().paused = true
		await get_tree().create_timer(2).timeout
		get_parent().levelFinished(int(levelName), false)
	return

func deleteMatches() -> void:
	var conditionDictionary: Dictionary = {ConditionType1: 0, ConditionType2: 0}
	conditionDictionary = await grid.deleteMatches(conditionDictionary)
	updateNumberConditions(conditionDictionary[ConditionType1], conditionDictionary[ConditionType2])

func updateNumberConditions(numberDeletedCondition1: int, numberDeletedCondition2: int) -> void:
	numberForCondition1 -=  numberDeletedCondition1
	numberForCondition2 -=  numberDeletedCondition2
	if numberForCondition1 <= 0:
		numberForCondition1 = 0
	hud.updateNbCondition1(numberForCondition1)
	if numberForCondition2 <= 0:
		numberForCondition2 = 0
	hud.updateNbCondition2(numberForCondition2)
	if numberForCondition1 <= 0 and numberForCondition2 <= 0:
		state = gameOver

func getPowerUpInput() -> void:
	if carrotButtonReleased and Input.is_action_just_pressed("ui_touch"):
		var touchCoords: Vector2 = get_global_mouse_position()
		if grid.isInGrid(touchCoords):
			var tileTouched: Vector2 = grid.getTilePositionFromCoords(touchCoords)
			if !grid.isTileEmpty(tileTouched):
				state = treatPowerUp
				var blockTypeDeleted: String = await grid.deleteTile(tileTouched)
				if blockTypeDeleted == ConditionType1:
					updateNumberConditions(1,0)
				if blockTypeDeleted == ConditionType2:
					updateNumberConditions(0,1)
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

static func saveParameters(parametersDictionary: Dictionary, levelName:String) -> void:
	DirAccess.make_dir_recursive_absolute("res://levels")
	var filePath: String = "res://levels/level" + levelName + ".json"
	var saveFile = FileAccess.open(filePath, FileAccess.WRITE_READ)
	var parametersJSONString:String = JSON.stringify(parametersDictionary)
	saveFile.store_line(parametersJSONString)
