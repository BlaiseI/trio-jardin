class_name Grid
extends Node2D

enum {wait, checkMove, treatMove, resolveMatches, carrot}
var state

@onready var utils:Utils = $"../utilsCodeContainer"

@export var xStart: int
@export var yStart: int
@export var offset: int

var width: int
var height: int
var emptyTiles : PackedVector2Array
var webs : PackedVector2Array
var nbCarrots: int


var grid = []

var cadrePreload = preload("res://Scenes/cadre.tscn")
var webPreload = preload("res://Scenes/web.tscn")

var buttonReleasedAfterCarrot = false
var slideBeginCoords: Vector2
var slideBeginPosition: Position
var slideEndPosition: Position
var slideOngoing: bool = false

func initGrid() -> void:
	createEmptyGrid()
	fillGrid()

func createEmptyGrid() -> void:
	for i in height:
		grid.append([])
		for j in width:
			grid[i].append(null)
			var cadre: Block = cadrePreload.instantiate()
			add_child(cadre)
			cadre.position = utils.getTileCoordsFromPosition(Position.new(i,j), self)
			#cadre.get_node("CenterContainer/Control/Sprite2D").modulate.a = 0.2

func fillGrid() -> void:
	for i in height:
		for j in width:
			if !emptyTile(i,j):
				var block: Node = createNonMatchingBlock(i,j)
				add_child(block)
				block.position = utils.getTileCoordsFromPosition(Position.new(i,j), self)
				grid[i][j] = block
			if Vector2(i,j) in webs:
				var web: Node = webPreload.instantiate()
				web.position = utils.getTileCoordsFromPosition(Position.new(i,j), self)
				web.name = "web" + str(i) + str(j)
				add_child(web)

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
	return Vector2(row, column) in emptyTiles

func swapBlocks(firstPosition: Vector2, secondPosition: Vector2) -> void:
	var firstRow: int = firstPosition.x
	var firstCol: int = firstPosition.y
	var secondRow: int = secondPosition.x
	var secondCol: int = secondPosition.y

	grid[firstRow][firstCol].move(utils.getTileCoordsFromPosition(Position.new(secondRow, secondCol), self))
	await grid[secondRow][secondCol].move(utils.getTileCoordsFromPosition(Position.new(firstRow, firstCol), self))

	var tmp: Node2D = grid[firstRow][firstCol]
	grid[firstRow][firstCol] = grid[secondRow][secondCol]
	grid[secondRow][secondCol] = tmp

func shakeBlock(blockPos: Vector2) -> void:
	var tween = create_tween()
	var block:Block = grid[blockPos.x][blockPos.y]
	tween.tween_property(block, "position", block.position + Vector2(5,0), .10)
	tween.tween_property(block, "position", block.position + Vector2(-5,0), .20)
	tween.tween_property(block, "position", block.position + Vector2(0,0), .10)
	await tween.finished

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

func deleteMatches(conditionDictionary: Dictionary) -> Dictionary:
	var toShrink = []
	for i in height:
		for j in width:
			if grid[i][j] and grid[i][j].partOfMatch:
				toShrink.append(Vector2(i,j))
				if conditionDictionary.has(grid[i][j].blockType):
					conditionDictionary[grid[i][j].blockType] += 1

	var lastSignal : Signal
	for position in toShrink:
		if position in webs:
			lastSignal = get_node("web" + str(position.x) + str(position.y)).shrink()
		else:
			lastSignal = grid[position.x][position.y].shrink()
	await lastSignal

	for position in toShrink:
		var i = position.x
		var j = position.y
		if position in webs:
			var web: Web = get_node("web" + str(position.x) + str(position.y))
			remove_child(web)
			web.queue_free()
			webs.remove_at(webs.find(position))
		else:
			remove_child(grid[i][j])
			grid[i][j].queue_free()
			grid[i][j] = null
	return conditionDictionary

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
				var nbWebs: int = 0
				while(k >= 0 and grid[k][j]):
					if Vector2(k,j) in webs:
						nbWebs +=1
						k -= 1
					else:
						var newHeight: int = k+1+nbWebs
						lastSignal = grid[k][j].move(utils.getTileCoordsFromPosition(Position.new(newHeight, j), self))
						grid[newHeight][j] = grid[k][j]
						grid[k][j] = null
						k -= 1
						if nbWebs > 0:
							nbWebs = 0
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

func deleteTile(position: Vector2) -> String:
	var blockType: String = grid[position.x][position.y].blockType
	await grid[position.x][position.y].shrink()
	remove_child(grid[position.x][position.y])
	grid[position.x][position.y] = null
	return blockType

func getTilePositionFromCoords(coords: Vector2) -> Vector2:
	return Vector2(floor((coords.y - yStart)/offset), floor((coords.x - xStart)/offset))

func isInGrid(coords: Vector2) -> bool:
	if(coords.x < xStart or coords.x > xStart + (width*offset)
		or coords.y < yStart or coords.y > yStart + (height*offset)):
			return false
	return true
