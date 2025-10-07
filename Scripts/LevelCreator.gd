class_name LevelCreator
extends Node2D

@export var width: int = 8
@export var height: int = 8
@export var xStart: int
@export var yStart: int
@export var offset: int
@export var levelName: String = "1"
var grid = []
var gridCadres = []
var webs = []
var cadrePreload = preload("res://Scenes/cadre.tscn")
var webPreload = preload("res://Scenes/web.tscn")
var selectedBlock: String = "chardon"
var condition1: String = "null"
var numberForCondition1 = 0
var condition2: String = "null"
var numberForCondition2 = 0
var nbMovesLeft = 0
var nbDifferentBlocks: int = 4


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	createEmptyGrid()
	var cadre = cadrePreload.instantiate()
	cadre.name = "cadre"
	cadre.position = Vector2(49,89)
	#cadre.find_child("Sprite2D").zIndex = -1
	cadre.z_index = -1
	add_child(cadre)

func getTileCoords(position: Vector2) -> Vector2:
	var xCoord: int = xStart+30 + (position.y*offset)
	var yCoord: int = yStart+30 + (position.x*offset)
	return Vector2(xCoord,yCoord)

func saveLevel() -> void:
	var parametersDictionary: Dictionary = {
		"gridHeight":height,
		"gridWidth":width,
		"gridEmptyTiles":[],
		"gridWebs" : [],
		"gridRonce" : [],
		"gridLierre" : [],
		"fixedBlocks" : [],
		"nbDifferentBlocks":nbDifferentBlocks,
		"nbCarrots":1,
		"ConditionType1":condition1,
		"numberForCondition1":numberForCondition1,
		"ConditionType2":condition2,
		"numberForCondition2":numberForCondition2,
		"numberMovesLeft":nbMovesLeft
	}
	for i in height:
		for j in width:
			if(grid[i][j] == null):
				continue
			elif(grid[i][j] is Web):
				parametersDictionary["gridWebs"].append(Vector2(i,j))
			elif(grid[i][j].blockType == "empty"):
				parametersDictionary["gridEmptyTiles"].append(Vector2(i,j))
			elif(grid[i][j].blockType == "ronce"):
				parametersDictionary["gridRonce"].append(Vector2(i,j))
			elif(grid[i][j].blockType == "lierre"):
				parametersDictionary["gridLierre"].append(Vector2(i,j))
			else:
				parametersDictionary["fixedBlocks"].append([Vector2(i,j), grid[i][j].blockType])
	Level.saveParameters(parametersDictionary, levelName)

func getTilePositionFromCoords(coords: Vector2) -> Vector2:
	return Vector2(floor((coords.y - yStart)/offset), floor((coords.x - xStart)/offset))

func createEmptyGrid() -> void:
	for cadre in gridCadres:
		remove_child(cadre)
	for i in height:
		grid.append([])
		for j in width:
			grid[i].append(null)
			var cadre: Block = cadrePreload.instantiate()
			gridCadres.append(cadre)
			add_child(cadre)
			cadre.position = getTileCoords(Vector2(i,j))

func changeSelectedBlock(blockType: String, pos: Vector2):
	selectedBlock = blockType
	find_child("cadre", false, false).position = pos + Vector2(30,30)

func isInGrid(coords: Vector2) -> bool:
	if(coords.x < xStart or coords.x > xStart + (width*offset)
		or coords.y < yStart or coords.y > yStart + (height*offset)):
			return false
	return true

func isInCondition1(coords: Vector2) -> bool:
	if(coords.x < 370 or coords.x > 430 or coords.y < 860 or coords.y > 920):
			return false
	return true

func isInCondition2(coords: Vector2) -> bool:
	if(coords.x < 480 or coords.x > 540 or coords.y < 860 or coords.y > 920):
			return false
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_touch"):
		var touchCoords: Vector2 = get_global_mouse_position()
		print(touchCoords)
		if isInGrid(touchCoords):
			var tileTouched: Vector2 = getTilePositionFromCoords(touchCoords)
			var block
			if(selectedBlock == "web"):
				block = webPreload.instantiate()
			else:
				block = Block.createBlock(selectedBlock)
			block.position = getTileCoords(tileTouched)
			if(grid[tileTouched.x][tileTouched.y]):
				remove_child(grid[tileTouched.x][tileTouched.y])
			grid[tileTouched.x][tileTouched.y] = block
			add_child(block)
		elif isInCondition1(touchCoords):
			print("in condition 1")
			var block
			if(selectedBlock == "web"):
				block = webPreload.instantiate()
			else:
				block = Block.createBlock(selectedBlock)
			block.position = Vector2(400,890)
			block.name = "condition1"
			var last_block = find_child("condition1", true, false)
			if(last_block):
				remove_child(last_block)
			add_child(block)
			condition1 = selectedBlock
		elif isInCondition2(touchCoords):
			print("in condition 2")
			var block
			if(selectedBlock == "web"):
				block = webPreload.instantiate()
			else:
				block = Block.createBlock(selectedBlock)
			block.position = Vector2(510, 890)
			block.name = "condition2"
			var last_block = find_child("condition2", true, false)
			if(last_block):
				remove_child(last_block)
			add_child(block)
			condition2 = selectedBlock

func treatInput(type: String) -> void:
	if type.contains("height"):
		if type.contains("add"):
			height += 1
			$"HeightSelect/Number".text = str(height)
			createEmptyGrid()
		if type.contains("sub"):
			height -= 1
			$"HeightSelect/Number".text = str(height)
			createEmptyGrid()
	if type.contains("width"):
		if type.contains("add"):
			width += 1
			$"WidthSelect/Number".text = str(width)
			createEmptyGrid()
		if type.contains("sub"):
			width -= 1
			$"WidthSelect/Number".text = str(width)
			createEmptyGrid()
	if type.contains("level"):
		print("level")
		if type.contains("add"):
			print("add")
			levelName = str(int(levelName)+1)
			$"LevelSelect/Number".text = levelName
			print($"LevelSelect/Number".text)
		if type.contains("sub"):
			levelName = str(int(levelName)-1)
			$"LevelSelect/Number".text = levelName
	if type.contains("moves"):
		if type.contains("add"):
			nbMovesLeft += 1
			$"NbMovesLeftSelect/Number".text = str(nbMovesLeft)
		if type.contains("sub"):
			nbMovesLeft -= 1
			$"NbMovesLeftSelect/Number".text = str(nbMovesLeft)
	if type.contains("condition1"):
		if type.contains("add"):
			numberForCondition1 += 1
			$"Condition1Select/Number".text = str(numberForCondition1)
		if type.contains("sub"):
			numberForCondition1 -= 1
			$"Condition1Select/Number".text = str(numberForCondition1)
	if type.contains("condition2"):
		if type.contains("add"):
			numberForCondition2 += 1
			$"Condition2Select/Number".text = str(numberForCondition2)
		if type.contains("sub"):
			numberForCondition2 -= 1
			$"Condition2Select/Number".text = str(numberForCondition2)
	if type.contains("difBlocks"):
		if type.contains("add"):
			nbDifferentBlocks += 1
			$"DifBlockSelect/Number".text = str(nbDifferentBlocks)
		if type.contains("sub"):
			nbDifferentBlocks -= 1
			$"DifBlockSelect/Number".text = str(nbDifferentBlocks)
