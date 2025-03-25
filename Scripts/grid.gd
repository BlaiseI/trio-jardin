extends Node2D

enum{wait, checkMove, treatMove, resolveMatches}
var state

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
	#preload("res://Scenes/block_fifth.tscn")
]
var cadrePreload = preload("res://Scenes/cadre.tscn")
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var slideBeginCoords: Vector2
var slideEndCoords: Vector2 = Vector2(-1, -1)
var slideOngoing: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state = checkMove
	initGrid()
	
func printGrid() -> void:
	for i in height:
		for j in width:
			if not grid[i][j]:
				print("!! NULL!!",i,j)

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
			var block: Node
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
	var xCoord: int = xStart+30 + (position.column*offset)
	var yCoord: int = yStart+30 + (position.row*offset)
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
	await grid[secondRow][secondCol].move(getTileCoordsFromPosition(Position.new(secondRow, secondCol)))
	
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
	
func takeAboveMatches(row:int, column:int) -> int:
	var nbMatchesVertical:int = 0
	while row >= 0 and grid[row][column].partOfMatch:
		nbMatchesVertical += 1
		grid[row][column].partOfMatch = false
		row -= 1
	return nbMatchesVertical
	
func resolve() -> void:
	while(getMatchesOnGrid()):
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
		
		var lastSignalMove
		for i in height:
			for j in width:
				if !grid[i][j]:
					for k in range(i-1,-1,-1):
						if grid[k][j]:
							lastSignalMove = grid[k][j].move(getTileCoordsFromPosition(Position.new(k+1, j)))
							grid[k+1][j] = grid[k][j]
							grid[k][j] = null
		if lastSignalMove:
			await lastSignalMove
						
		var lastSignalCreate
		for i in height:
			for j in width:
				if grid[i][j] == null:
					var block:Node
					var blockIndex: int = rng.randi_range(0, blocks.size()-1)
					block = blocks[blockIndex].instantiate()
					block.position = getTileCoordsFromPosition(Position.new(i,j))
					add_child(block)
					lastSignalCreate = block.spawn()
					grid[i][j] = block
		await lastSignalCreate
	return
				#replaceBlock(Position.new(i, j))
				#await get_tree().create_timer(0.1).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	if treatingLastMovement:
#		return
#	if not getMatchesOnGrid():
#		getSlideCoords()
#	else:
#		treatingLastMovement = true
#		await resolve()
#		treatingLastMovement = false
#	if(slideEndCoords != Vector2(-1, -1)):
#		treatingLastMovement = true
#		
#		treatingLastMovement = false
		
func _process(delta: float) -> void:
	if state == checkMove:
		getSlideCoords()
		if(slideEndCoords != Vector2(-1, -1)):
			state = treatMove
	elif state == treatMove:
		state = wait
		var slideDirection: Vector2 = getSlideDirection()
		var firstBlockPosition: Position = getPositionFromTileCoords(slideBeginCoords)
		print("movement detected : ", firstBlockPosition.row, ", ", firstBlockPosition.column, ", ", slideDirection)
		var secondBlockPosition: Position = Position.new(firstBlockPosition.row + slideDirection.y, firstBlockPosition.column + slideDirection.x)
		if not firstBlockPosition.equals(secondBlockPosition):
			await swapBlocks(firstBlockPosition, secondBlockPosition)
			if not getMatchesOnGrid():
				swapBlocks(firstBlockPosition, secondBlockPosition)
		slideEndCoords = Vector2(-1, -1)
		state = resolveMatches
	elif state == resolveMatches:
		state = wait
		await resolve()
		state = checkMove
