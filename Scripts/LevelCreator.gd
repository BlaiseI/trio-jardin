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
var blockSelectorPreload = preload("res://Scenes/block_selector.tscn")
var selectedBlock: BlockSelector
var conditions = []
var nbMovesLeft = 0
var nbDifferentBlocks: int = 4


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadBlockList("res://levelCreator/blockList.json")
	loadLevelParameters("res://levels/level" + levelName + ".json")
	var cadre = cadrePreload.instantiate()
	cadre.name = "cadre"
	cadre.position = Vector2(49,89)
	#cadre.find_child("Sprite2D").zIndex = -1
	cadre.z_index = -1
	add_child(cadre)

func updateCondition(selectedBlock : String, i: int) -> void:
	conditions[i][0] = selectedBlock
	var block
	if(selectedBlock == "null"):
		var last_block = find_child("condition" + str(i+1), true, false)
		if(last_block):
			remove_child(last_block)
		return
	block = Block.createBlock(selectedBlock)
	block.name = "condition" + str(i+1)
	block.position = Vector2(394 + ((i%2)*120), 870 + ((i/2)*76))
	var last_block = find_child(block.name, true, false)
	if(last_block):
		remove_child(last_block)
	add_child(block)

func loadBlockList(filePath: String) -> void:
	var saveFile:FileAccess = FileAccess.open(filePath, FileAccess.READ)
	var blocksJSONString = saveFile.get_line()
	var blocksJSON = JSON.new()
	blocksJSON.parse(blocksJSONString)
	var blocksDictionary: Dictionary = blocksJSON.data
	for blockType : String in blocksDictionary["blockList"] :
		var selector : BlockSelector = blockSelectorPreload.instantiate()
		selector.blockType = blockType
		$"BlocksScrollBar/BlocksList".add_child(selector)

func loadLevelParameters(filePath: String) -> void:
	for block in find_children("block*", "", true, false):
		remove_child(block)
	var saveFile:FileAccess = FileAccess.open(filePath, FileAccess.READ)
	var paramsJSONString = saveFile.get_line()
	var paramsJSON = JSON.new()
	paramsJSON.parse(paramsJSONString)
	var parametersDictionary: Dictionary = paramsJSON.data
	height = parametersDictionary["gridHeight"]
	width = parametersDictionary["gridWidth"]
	createEmptyGrid()
	for positionString: String in parametersDictionary["gridEmptyTiles"]:
		var positionVector:Vector2 = str_to_var("Vector2" + positionString)
		var block = Block.createBlock("empty")
		block.position = getTileCoords(positionVector)
		grid[positionVector.x][positionVector.y] = block
		add_child(block)
	for fixedBlock: Array in parametersDictionary["fixedBlocks"]:
		var positionVector:Vector2 = str_to_var("Vector2" + fixedBlock[0])
		var block = Block.createBlock(fixedBlock[1])
		block.position = getTileCoords(positionVector)
		grid[positionVector.x][positionVector.y] = block
		add_child(block)
	for positionString: String in parametersDictionary["gridRonce"]:
		var positionVector:Vector2 = str_to_var("Vector2" + positionString)
		var block = Block.createBlock("ronce")
		block.position = getTileCoords(positionVector)
		grid[positionVector.x][positionVector.y] = block
		add_child(block)
	for lierreInfo: Array in parametersDictionary["gridLierre"]:
		lierreInfo[0] = str_to_var("Vector2" + lierreInfo[0])
		var block = Block.createBlock("lierre")
		block.layers = lierreInfo[1]
		block.position = getTileCoords(lierreInfo[0])
		grid[lierreInfo[0].x][lierreInfo[0].y] = block
		add_child(block)

	nbDifferentBlocks = parametersDictionary["nbDifferentBlocks"]
	conditions = parametersDictionary["conditions"]
	for i in range(4):
		if i >= conditions.size():
			find_child("ConditionBackground" + str(i+1)).find_child("ConditionTexture").texture = null
			conditions.append(["null", 0])
			continue
		updateCondition(conditions[i][0],i)
		find_child("Condition" + str(i+1) + "Select", false, false).find_child("Number", false).text = str(conditions[i][1])

	nbMovesLeft = parametersDictionary["numberMovesLeft"]

	$"HeightSelect/Number".text = str(height)
	$"WidthSelect/Number".text = str(width)
	$"LevelSelect/Number".text = levelName
	$"NbMovesLeftSelect/Number".text = str(nbMovesLeft)
	$"DifBlockSelect/Number".text = str(nbDifferentBlocks)

func getTileCoords(position: Vector2) -> Vector2:
	var xCoord: int = xStart+30 + (position.y*offset)
	var yCoord: int = yStart+30 + (position.x*offset)
	return Vector2(xCoord,yCoord)

func saveLevel() -> void:
	var parametersDictionary: Dictionary = {
		"gridHeight":height,
		"gridWidth":width,
		"gridEmptyTiles":[],
		"gridRonce" : [],
		"gridLierre" : [],
		"fixedBlocks" : [],
		"nbDifferentBlocks":nbDifferentBlocks,
		"numberMovesLeft":nbMovesLeft,
		"conditions" : []
	}
	for condition in conditions:
		if condition[0] != "null":
			parametersDictionary["conditions"].append(condition)
	for i in height:
		for j in width:
			if(grid[i][j] == null):
				continue
			elif(grid[i][j].blockType == "empty"):
				parametersDictionary["gridEmptyTiles"].append(Vector2(i,j))
			elif(grid[i][j].blockType == "ronce"):
				parametersDictionary["gridRonce"].append(Vector2(i,j))
			elif(grid[i][j].blockType == "lierre"):
				parametersDictionary["gridLierre"].append([Vector2(i,j),grid[i][j].layers])
			elif(grid[i][j] is Web):
				parametersDictionary["fixedBlocks"].append([Vector2(i,j), "web"])
			else:
				parametersDictionary["fixedBlocks"].append([Vector2(i,j), grid[i][j].blockType])
	Level.saveParameters(parametersDictionary, levelName)

func getTilePositionFromCoords(coords: Vector2) -> Vector2:
	return Vector2(floor((coords.y - yStart)/offset), floor((coords.x - xStart)/offset))

func createEmptyGrid() -> void:
	grid = []
	for cadre in gridCadres:
		remove_child(cadre)
	for row in grid:
		for elem in row:
				remove_child(elem)
	for i in height:
		grid.append([])
		for j in width:
			grid[i].append(null)
			var cadre: Block = cadrePreload.instantiate()
			gridCadres.append(cadre)
			add_child(cadre)
			cadre.position = getTileCoords(Vector2(i,j))

func changeSelectedBlock(blockSelector: BlockSelector, pos: Vector2):
	if selectedBlock :
		selectedBlock.toggleCadre()
	selectedBlock = blockSelector
	selectedBlock.toggleCadre()
	#find_child("cadre", false, false).position = pos + Vector2(30,30)

func isInGrid(coords: Vector2) -> bool:
	if(coords.x < xStart or coords.x > xStart + (width*offset)
		or coords.y < yStart or coords.y > yStart + (height*offset)):
			return false
	return true

func isInCondition(coords: Vector2) -> int:
	for i in range(4):
		var conditionXStart = 364 + ((i%2)*100)
		var conditionXEnd = conditionXStart + 80
		var conditionYStart = 840 + ((i/2)*80)
		var conditionYEnd = conditionYStart + 60
		if(coords.x < conditionXStart or coords.x > conditionXEnd or coords.y < conditionYStart or coords.y > conditionYEnd):
				continue
		return i
	return -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_touch"):
		var touchCoords: Vector2 = get_global_mouse_position()
		if isInGrid(touchCoords):
			var tileTouched: Vector2 = getTilePositionFromCoords(touchCoords)
			if selectedBlock.blockType == "null":
				if(grid[tileTouched.x][tileTouched.y]):
					remove_child(grid[tileTouched.x][tileTouched.y])
					grid[tileTouched.x][tileTouched.y] = null
				return
			var block
			if(selectedBlock.blockType == "lierre"):
				var currentBlock = grid[tileTouched.x][tileTouched.y]
				if (currentBlock and currentBlock.blockType == "lierre"):
					if currentBlock.layers < 3:
						block = Block.createBlock(selectedBlock.blockType)
						block.layers = currentBlock.layers + 1
					else:
						return
				else:
					block = Block.createBlock(selectedBlock.blockType)
					block.layers = 1
			else:
				block = Block.createBlock(selectedBlock.blockType)
			block.position = getTileCoords(tileTouched)
			if(grid[tileTouched.x][tileTouched.y]):
				remove_child(grid[tileTouched.x][tileTouched.y])
			grid[tileTouched.x][tileTouched.y] = block
			add_child(block)
		elif isInCondition(touchCoords) != -1:
			updateCondition(selectedBlock.blockType, isInCondition(touchCoords))

func treatInput(type: String) -> void:
	if type.contains("height"):
		if type.contains("add"):
			height += 1
		if type.contains("sub"):
			height -= 1
		$"HeightSelect/Number".text = str(height)
		createEmptyGrid()
	if type.contains("width"):
		if type.contains("add"):
			width += 1
		if type.contains("sub"):
			width -= 1
		$"WidthSelect/Number".text = str(width)
		createEmptyGrid()
	if type.contains("level"):
		if type.contains("add"):
			levelName = str(int(levelName)+1)
		if type.contains("sub"):
			levelName = str(int(levelName)-1)
		$"LevelSelect/Number".text = levelName
		loadLevelParameters("res://levels/level" + levelName + ".json")
	if type.contains("moves"):
		if type.contains("add"):
			nbMovesLeft += 1
			$"NbMovesLeftSelect/Number".text = str(nbMovesLeft)
		if type.contains("sub"):
			nbMovesLeft -= 1
			$"NbMovesLeftSelect/Number".text = str(nbMovesLeft)
	if type.contains("condition"):
		for i in range(conditions.size()):
			if type.contains(str(i+1)):
				if type.contains("add"):
					conditions[i][1] += 1
				if type.contains("sub"):
					conditions[i][1] -= 1
				find_child("Condition" + str(i+1) + "Select", false, false).find_child("Number", false).text = str(conditions[i][1])
	if type.contains("difBlocks"):
		if type.contains("add"):
			nbDifferentBlocks += 1
			$"DifBlockSelect/Number".text = str(nbDifferentBlocks)
		if type.contains("sub"):
			nbDifferentBlocks -= 1
			$"DifBlockSelect/Number".text = str(nbDifferentBlocks)

func printGrid() -> void:
	var toPrint: String = ""
	toPrint += "["
	for row in grid:
		toPrint += "["
		for elem in row :
			if(elem):
				toPrint += elem.blockType + ", "
			else:
				toPrint += "null, "
		toPrint += "]"
	toPrint += "]"
	print(toPrint)
