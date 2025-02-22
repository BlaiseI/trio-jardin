extends Node2D

@export var width: int
@export var height: int
@export var xStart: int
@export var yStart: int
@export var offset: int

var grid = []
var blocks = [
	preload("res://Scenes/block_chardon.tscn"),
	preload("res://Scenes/block_chenille.tscn"),
	preload("res://Scenes/block_ortie.tscn"),
	preload("res://Scenes/block_egopode.tscn")
]
var cadrePreload = preload("res://Scenes/cadre.tscn")
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var slideBeginCoords: Vector2
var slideEndCoords: Vector2 = Vector2(-1, -1)
var slideOngoing: bool = false

var waiting: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initGrid()

func initGrid() -> void:
	for i in height:
		grid.append([])
		for j in width:
			grid[i].append(null)
			var cadre = cadrePreload.instantiate()
			add_child(cadre)
			cadre.position = getTileCoordsFromPosition(Position.new(i,j))
	for i in height:
		for j in width:
			var isMatch: bool = true
			var block
			while(isMatch):
				var blockIndex: int = rng.randi_range(0, blocks.size()-1)
				block = blocks[blockIndex].instantiate()
				if not givesMatch(j,i,block) :
					isMatch = false
			add_child(block)
			block.position = getTileCoordsFromPosition(Position.new(i,j))
			grid[i][j] = block
	pass
	
func givesMatch(row: int, column: int, block) -> bool:
	if row >= 2 :
		if (block.blockType == grid[column][row-1].blockType and block.blockType == grid[column][row-2].blockType):
			return true
	if column >= 2 :
		if (block.blockType == grid[column-1][row].blockType and block.blockType == grid[column-2][row].blockType):
			return true	
	return false

func getTileCoordsFromPosition(position: Position) -> Vector2:
	var xCoord: int = xStart + (position.column*offset)
	var yCoord: int = yStart + (position.row*offset)
	return Vector2(xCoord,yCoord)
	
func getPositionFromTileCoords(coords: Vector2) -> Position:
	if (coords.x < xStart or coords.x > xStart + (width*offset) or coords.y < yStart or coords.y > yStart + (height*offset)):
		return Position.getNull()
	return Position.new( floor((coords.y - yStart)/offset), floor((coords.x - xStart)/offset))
	
func getSlideCoords() -> void:
	if Input.is_action_just_pressed("ui_touch"):
		slideBeginCoords = get_global_mouse_position()
		if(slideBeginCoords.x >= xStart and slideBeginCoords.y >= yStart and slideBeginCoords.x < xStart + (width*offset) and slideBeginCoords.y < yStart + (height*offset)):
			slideOngoing = true
	if Input.is_action_just_released("ui_touch"):
		slideEndCoords = get_global_mouse_position()
		if not (slideOngoing and slideEndCoords.x >= xStart and slideEndCoords.y >= yStart and slideEndCoords.x < xStart + (width*offset) and slideEndCoords.y < yStart + (height*offset)):
			slideOngoing = false
			slideEndCoords = Vector2(-1, -1)

func getSlideDirection() -> Vector2:
	var xDif : float = slideEndCoords.x - slideBeginCoords.x
	var yDif : float = slideEndCoords.y - slideBeginCoords.y
	var ratio = abs(xDif/yDif)
	if (ratio > 2):
		if(xDif > 0):
			return Vector2(1, 0)
		else:
			return Vector2(-1, 0)
	if(ratio < 0.5):
		if(yDif>0):
			return Vector2(0, 1)
		else:
			return Vector2(0, -1)
	return Vector2(0, 0)

func swapBlocks(firstPosition: Position, secondPosition: Position) -> void:
	var firstRow: int = firstPosition.row
	var firstCol: int = firstPosition.column
	var secondRow: int = secondPosition.row
	var secondCol: int = secondPosition.column
	
	var tmp: Node2D = grid[firstRow][firstCol]
	grid[firstRow][firstCol] = grid[secondRow][secondCol]
	grid[firstRow][firstCol].move(getTileCoordsFromPosition(Position.new(firstRow, firstCol)))
	grid[secondRow][secondCol] = tmp
	grid[secondRow][secondCol].move(getTileCoordsFromPosition(Position.new(secondRow, secondCol)))
	
	print("new block position : ", grid[firstRow][firstCol].blockType, ", ", grid[secondRow][secondCol].blockType)
	
func getMatchesOnGrid() -> bool:
	var thereIsAMatch: bool = false
	for row in height:
		for column in width:
			var blockType: String = grid[row][column].blockType
			if(row >= 2 && grid[row-1][column].blockType == blockType and grid[row-2][column].blockType == blockType):
				grid[row-2][column].partOfMatch = true
				grid[row-1][column].partOfMatch = true
				grid[row][column].partOfMatch = true
				thereIsAMatch = true
			if(column >= 2 && grid[row][column-1].blockType == blockType and grid[row][column-2].blockType == blockType):
				grid[row][column-2].partOfMatch = true
				grid[row][column-1].partOfMatch = true
				grid[row][column].partOfMatch = true
				thereIsAMatch = true
	return thereIsAMatch
	
func replaceBlock(blockPosition: Position) -> int:
	var row:int = blockPosition.row
	var column: int = blockPosition.column
	var blockIndex: int = rng.randi_range(0, blocks.size()-1)
	print("replacing ", grid[row][column].blockType, " by ", blocks[blockIndex].instantiate().blockType, " in ", row, ", ", column)
	remove_child(grid[row][column])
	grid[row][column] = blocks[blockIndex].instantiate()
	grid[row][column].position = getTileCoordsFromPosition(Position.new(row,column))
	add_child(grid[row][column])
	return 1
	
func resolve() -> void:
	for i in height:
		for j in width:
			if grid[i][j].partOfMatch:
				replaceBlock(Position.new(i, j))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not getMatchesOnGrid():
		getSlideCoords()
	else:
		resolve()
	if(slideEndCoords != Vector2(-1, -1)):
		var slideDirection: Vector2 = getSlideDirection()
		var firstBlockPosition: Position = getPositionFromTileCoords(slideBeginCoords)
		print("movement detected : ", firstBlockPosition.row, ", ", firstBlockPosition.column, ", ", slideDirection)
		var secondBlockPosition: Position = Position.new(firstBlockPosition.row + slideDirection.y, firstBlockPosition.column + slideDirection.x)
		if not firstBlockPosition.equals(secondBlockPosition):
			swapBlocks(firstBlockPosition, secondBlockPosition)
			if not getMatchesOnGrid():
				swapBlocks(firstBlockPosition, secondBlockPosition)
		slideEndCoords = Vector2(-1, -1)
