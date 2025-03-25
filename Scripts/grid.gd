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

var grid = []

var cadrePreload = preload("res://Scenes/cadre.tscn")

var slideBeginCoords: Vector2
var slideEndCoords: Vector2 = Vector2(-1, -1)
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
			var cadre = cadrePreload.instantiate()
			add_child(cadre)
			cadre.position = utils.getTileCoordsFromPosition(Position.new(i,j), self)

func fillGrid() -> void:
	for i in height:
		for j in width:
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
		if not givesMatch(column, row, block) :
			isMatch = false
	return block

func givesMatch(row: int, column: int, block) -> bool:
	if row >= 2 :
		if (block.blockType == grid[column][row-1].blockType and block.blockType == grid[column][row-2].blockType):
			return true
	if column >= 2 :
		if (block.blockType == grid[column-1][row].blockType and block.blockType == grid[column-2][row].blockType):
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
		if(slideBeginCoords.x >= xStart and slideBeginCoords.y >= yStart and slideBeginCoords.x < xStart + (width*offset) and slideBeginCoords.y < yStart + (height*offset)):
			slideOngoing = true
	if Input.is_action_just_released("ui_touch"):
		slideEndCoords = get_global_mouse_position()
		if (slideOngoing and slideEndCoords.x >= xStart and slideEndCoords.y >= yStart and slideEndCoords.x < xStart + (width*offset) and slideEndCoords.y < yStart + (height*offset)):
			state = treatMove
		else:
			state = checkMove
		slideOngoing = false
		
func treatMovement() -> void:
	state = wait

	var slideDirection: Vector2 = utils.getSlideDirection(slideBeginCoords, slideEndCoords)
	var firstBlockPosition: Position = utils.getPositionFromTileCoords(slideBeginCoords, self)
	var secondBlockPosition: Position = Position.new(firstBlockPosition.row + slideDirection.y, firstBlockPosition.column + slideDirection.x)

	if not firstBlockPosition.equals(secondBlockPosition):
		await swapBlocks(firstBlockPosition, secondBlockPosition)
		if not getMatchesOnGrid():
			await swapBlocks(firstBlockPosition, secondBlockPosition)

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

func getBlocksDown() -> void:
	var lastSignal
	for i in height:
		for j in width:
			if !grid[i][j]:
				for k in range(i-1,-1,-1):
					if grid[k][j]:
						lastSignal = grid[k][j].move(utils.getTileCoordsFromPosition(Position.new(k+1, j), self))
						grid[k+1][j] = grid[k][j]
						grid[k][j] = null
	if lastSignal:
		await lastSignal
	
func fillEmptyBlocks() -> void:
	var lastSignal
	for i in height:
		for j in width:
			if grid[i][j] == null:
				var block:Node = Block.createRandomBlock()
				block.position = utils.getTileCoordsFromPosition(Position.new(i,j), self)
				add_child(block)
				lastSignal = block.spawn()
				grid[i][j] = block
	await lastSignal
