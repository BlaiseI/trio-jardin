class_name LevelCreator
extends Node2D

@export var width: int = 8
@export var height: int = 8
@export var xStart: int
@export var yStart: int
@export var offset: int
@export var levelName: String = "1"
var grid = []
var webs = []
var cadrePreload = preload("res://Scenes/cadre.tscn")
var webPreload = preload("res://Scenes/web.tscn")
var selectedBlock: String = "chardon"

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
		"nbDifferentBlocks":4,
		"nbCarrots":1,
		"ConditionType1":"chardon",
		"numberForCondition1":11,
		"ConditionType2":"null",
		"numberForCondition2":0,
		"numberMovesLeft":3
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
	for i in height:
		grid.append([])
		for j in width:
			grid[i].append(null)
			var cadre: Block = cadrePreload.instantiate()
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_touch"):
		var touchCoords: Vector2 = get_global_mouse_position()
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
