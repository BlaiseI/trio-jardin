class_name Grid
extends Node2D

enum{wait, checkMove, treatMove, resolveMatches}
var state

@onready var utils = $"../utilsCodeContainer"

@export var width: int
@export var height: int
@export var xStart: int
@export var yStart: int
@export var offset: int
@export var emptyTiles : PackedVector2Array

var grid = []

var cadrePreload = preload("res://Scenes/cadre.tscn")

var slideBeginCoords: Vector2
var slideBeginPosition: Position
var slideEndPosition: Position
var slideOngoing: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state = checkMove
	initGrid()

func initGrid() -> void:
	createEmptyGrid()
	fillGrid()
	
func createEmptyGrid() -> void:
	for i in height:
		grid.append([])
		for j in width:
			grid[i].append(null)
			if !emptyTile(i,j):
				var cadre: Block = cadrePreload.instantiate()
				add_child(cadre)
				cadre.position = utils.getTileCoordsFromPosition(Position.new(i,j), self)
				cadre.get_node("CenterContainer/Control/Sprite2D").modulate.a = 0.2

func fillGrid() -> void:
	for i in height:
		for j in width:
			if !emptyTile(i,j):
				var isMatch: bool = true
				var block: Node = createNonMatchingBlock(i,j)
				add_child(block)
				block.position = utils.getTileCoordsFromPosition(Position.new(i,j), self)
				grid[i][j] = block

func createNonMatchingBlock(row: int, column: int) -> Block:
	var block: Block
	var isMatch: bool = true
	while(isMatch):
		block = Block.createRandomBlock()
		if not givesMatch(row, column, block) :
			isMatch = false
	return block

func givesMatch(row: int, column: int, block) -> bool:
	if column >= 2 and !emptyTile(row,column-1) and !emptyTile(row,column-2):
		if (block.blockType == grid[row][column-1].blockType and block.blockType == grid[row][column-2].blockType):
			return true
	if row >= 2 and !emptyTile(row-1,column) and !emptyTile(row-2,column):
		if (block.blockType == grid[row-1][column].blockType and block.blockType == grid[row-2][column].blockType):
			return true
	return false

func emptyTile(row: int, column:int) -> bool:
	for coords: Vector2 in emptyTiles:
		if coords == Vector2(row, column):
			return true
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.		
func _process(delta: float) -> void:
	if state == checkMove:
		checkMovement()
	elif state == treatMove:
		treatMovement()
	elif state == resolveMatches:
		resolve()
		
func checkMovement() -> void:
	if Input.is_action_just_pressed("ui_touch"):
		slideBeginCoords = get_global_mouse_position()
		slideBeginPosition = utils.getPositionFromTileCoords(slideBeginCoords, self)
		var row: int = slideBeginPosition.row
		var column: int = slideBeginPosition.column
		if(!emptyTile(row, column) and row >= 0 and column >= 0 and row < 8 and column < 8):
			slideOngoing = true
	if Input.is_action_just_released("ui_touch"):
		var slideEndCoords = get_global_mouse_position()
		var slideDirection: Vector2 = utils.getSlideDirection(slideBeginCoords, slideEndCoords)
		slideEndPosition = Position.new(slideBeginPosition.row + slideDirection.y, slideBeginPosition.column + slideDirection.x)
		if (!emptyTile(slideEndPosition.row, slideEndPosition.column) and slideOngoing):
			state = treatMove
		else:
			state = checkMove
		slideOngoing = false
		
func treatMovement() -> void:
	state = wait

	if not slideBeginPosition.equals(slideEndPosition):
		await swapBlocks(slideBeginPosition, slideEndPosition)
		if not getMatchesOnGrid():
			await swapBlocks(slideBeginPosition, slideEndPosition)

	state = resolveMatches

func swapBlocks(firstPosition: Position, secondPosition: Position) -> void:
	var firstRow: int = firstPosition.row
	var firstCol: int = firstPosition.column
	var secondRow: int = secondPosition.row
	var secondCol: int = secondPosition.column
	
	grid[firstRow][firstCol].move(utils.getTileCoordsFromPosition(Position.new(secondRow, secondCol), self))
	await grid[secondRow][secondCol].move(utils.getTileCoordsFromPosition(Position.new(firstRow, firstCol), self))
	
	var tmp: Node2D = grid[firstRow][firstCol]
	grid[firstRow][firstCol] = grid[secondRow][secondCol]
	grid[secondRow][secondCol] = tmp

func getMatchesOnGrid() -> bool:
	var thereIsAMatch: bool = false
	for row in height:
		for column in width:
			if !emptyTile(row,column):
				var blockType: String = grid[row][column].blockType
				if(row >= 2 && !emptyTile(row-1,column) && grid[row-1][column].blockType == blockType and !emptyTile(row-2,column) && grid[row-2][column].blockType == blockType):
					grid[row-2][column].partOfMatch = true
					grid[row-1][column].partOfMatch = true
					grid[row][column].partOfMatch = true
					thereIsAMatch = true
				if(column >= 2 && !emptyTile(row,column-1) && grid[row][column-1].blockType == blockType and !emptyTile(row,column-2) && grid[row][column-2].blockType == blockType):
					grid[row][column-2].partOfMatch = true
					grid[row][column-1].partOfMatch = true
					grid[row][column].partOfMatch = true
					thereIsAMatch = true
	return thereIsAMatch

func resolve() -> void:
	state = wait
	
	while(getMatchesOnGrid()):
		await deleteMatches()
		await getBlocksDown()
		await fillEmptyBlocks()
		
	state = checkMove
	return
	
func deleteMatches() -> void:
	var toShrink = []
	for i in height:
		for j in width:
			if grid[i][j] and grid[i][j].partOfMatch:
				toShrink.append(Position.new(i,j))
				
	var lastSignal : Signal
	for position in toShrink:
		lastSignal = grid[position.row][position.column].shrink()
	await lastSignal
	
	for position in toShrink:
		var i = position.row
		var j = position.column	
		remove_child(grid[i][j])
		grid[i][j].queue_free()
		grid[i][j] = null

func getBlocksDown2() -> void:
	var lastSignal
	for i in range(height-1,-1,-1):
		for j in width:
			if !grid[i][j] and !emptyTile(i,j):
				for k in range(i-1,-1,-1):
					if grid[k][j]:
						lastSignal = grid[k][j].move(utils.getTileCoordsFromPosition(Position.new(i, j), self))
						grid[i][j] = grid[k][j]
						grid[k][j] = null
						break
	if lastSignal:
		await lastSignal
		
func getBlocksDown() -> void:
	var lastSignal
	for i in height:
		for j in width:
			if !grid[i][j] and !emptyTile(i,j):
				var k: int = i-1
				while(k >= 0 and grid[k][j]):
					lastSignal = grid[k][j].move(utils.getTileCoordsFromPosition(Position.new(k+1, j), self))
					grid[k+1][j] = grid[k][j]
					grid[k][j] = null
					k -= 1
	if lastSignal:
		await lastSignal
	
func fillEmptyBlocks() -> void:
	var lastSignal
	for i in height:
		for j in width:
			if grid[i][j] == null and !emptyTile(i,j):
				var block:Node = Block.createRandomBlock()
				block.position = utils.getTileCoordsFromPosition(Position.new(i,j), self)
				add_child(block)
				lastSignal = block.spawn()
				grid[i][j] = block
	await lastSignal
