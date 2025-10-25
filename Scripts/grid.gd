class_name Grid
extends Node2D

enum {wait, checkMove, treatMove, resolveMatches, carrot}
var state

@onready var utils:Utils = $"../utilsCodeContainer"
@onready var level:Level = $".."

@export var xStart: int
@export var yStart: int
@export var offset: int


static var classesToInit = [Ronce, Lierre]

var width: int
var height: int
var emptyTiles : PackedVector2Array
var fixedBlocks = []
var webs : PackedVector2Array
var toTreat = []
var matches = []
var nbCarrots: int
var powerUps: Array = ["firecracker", "mouton"]

var grid = []

var cadrePreload = preload("res://Scenes/cadre.tscn")
var webPreload = preload("res://Scenes/web.tscn")
var firecrakerPreload = preload("res://Scenes/block_firecracker.tscn")
var moutonPreload = preload("res://Scenes/block_mouton.tscn")

var buttonReleasedAfterCarrot = false
var slideBeginCoords: Vector2
var slideBeginPosition: Position
var slideEndPosition: Position
var slideOngoing: bool = false
var debug = false

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
			cadre.position = utils.getTileCoords(Vector2(i,j), self)

func fillGrid() -> void:
	for i in height:
		for j in width:
			if !emptyTile(i,j):
				var block: Node = createNonMatchingBlock(i,j)
				add_child(block)
				block.position = utils.getTileCoords(Vector2(i,j), self)
				grid[i][j] = block
			if Vector2(i,j) in webs:
				var web: Node = webPreload.instantiate()
				web.position = utils.getTileCoords(Vector2(i,j), self)
				web.name = "web" + str(i) + str(j)
				add_child(web)
	for fixedBlock in fixedBlocks:
		match fixedBlock:
			[var coords, var blockType]:
				replaceBlock(coords, Block.createBlock(blockType))
	for _class in classesToInit:
		_class.init(self)

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
	var firstBlock : Block = grid[firstPosition.x][firstPosition.y]
	var secondBlock : Block = grid[secondPosition.x][secondPosition.y]

	if(firstBlock.blockType in powerUps):
		uniqueAdd(toTreat,secondPosition)
	if(secondBlock.blockType in powerUps):
		uniqueAdd(toTreat,firstPosition)

	firstBlock.move(utils.getTileCoords(secondPosition, self))
	await secondBlock.move(utils.getTileCoords(firstPosition, self))

	grid[firstPosition.x][firstPosition.y] = secondBlock
	grid[secondPosition.x][secondPosition.y] = firstBlock

func shakeBlocks(firstPos: Vector2, secondPos: Vector2) -> void:
	var tween = create_tween()
	var block:Block = grid[firstPos.x][firstPos.y]
	tween.tween_property(block, "position", block.position + Vector2(5,0), .10)
	tween.tween_property(block, "position", block.position + Vector2(-5,0), .20)
	tween.tween_property(block, "position", block.position, .10)
	var secondTween = create_tween()
	block = grid[secondPos.x][secondPos.y]
	secondTween.tween_property(block, "position", block.position + Vector2(-5,0), .10)
	secondTween.tween_property(block, "position", block.position + Vector2(5,0), .20)
	secondTween.tween_property(block, "position", block.position, .10)
	await tween.finished
	await secondTween.finished

func uniqueAdd(array: Array, element):
	if element not in array:
		array.push_back(element)

func addToMatches(positions: Array) -> void:
	var found :int = -1
	for matchIndex in range(matches.size()):
		for pos in positions:
			if pos in matches[matchIndex][1]:
				found = matchIndex
				break
		if found != -1:
			break
	if found != -1:
		for pos in positions:
			if pos not in matches[found][1]:
				matches[found][0] += 1
				matches[found][1].append(pos)
	else :
		matches.append([positions.size(), positions])

func canMatch(row, column) -> bool:
	return (row >= 0 and row < height and column >= 0 and column < width and !emptyTile(row,column) and grid[row][column].doesMatch)

func shuffle() -> void:
	var lastSignal: Signal
	for row in height:
		for column in width:
			if (canMatch(row, column)):
				lastSignal = grid[row][column].shrink()
	await lastSignal
	for row in height:
		for column in width:
			if (canMatch(row, column)):
				remove_child(grid[row][column])
				grid[row][column].queue_free()
				var block:Node = createNonMatchingBlock(row, column)
				block.position = utils.getTileCoords(Vector2(row,column), self)
				add_child(block)
				lastSignal = block.spawn()
				grid[row][column] = block
	await lastSignal

func enforcePossibleMatches() -> void:
	for row in height:
		for column in width:
			if (canMatch(row, column)):
				var matchingType = grid[row][column].blockType
				if(canMatch(row-1, column) and grid[row-1][column].blockType == matchingType):
					if(canMatch(row-3, column) and grid[row-3][column].blockType == matchingType
					or canMatch(row-2, column-1) and grid[row-2][column-1].blockType == matchingType
					or canMatch(row-2, column+1) and grid[row-2][column+1].blockType == matchingType
					or canMatch(row+1, column-1) and grid[row+1][column-1].blockType == matchingType
					or canMatch(row+1, column+1) and grid[row+1][column+1].blockType == matchingType
					or canMatch(row+2, column) and grid[row+2][column].blockType == matchingType):
						return
				if(canMatch(row, column-1) and grid[row][column-1].blockType == matchingType):
					if(canMatch(row, column-3) and grid[row][column-3].blockType == matchingType
					or canMatch(row-1, column-2) and grid[row-1][column-2].blockType == matchingType
					or canMatch(row+1, column-2) and grid[row+1][column-2].blockType == matchingType
					or canMatch(row-1, column+1) and grid[row-1][column+1].blockType == matchingType
					or canMatch(row+1, column+1) and grid[row+1][column+1].blockType == matchingType
					or canMatch(row, column+2) and grid[row][column+2].blockType == matchingType):
						return
	await $"..".displayShuffle()
	await shuffle()
	await enforcePossibleMatches()

func getMatchesOnGrid() -> bool:
	var thereIsAMatch: bool = !toTreat.is_empty()
	for row in height:
		for column in width:
			if (!emptyTile(row,column) and grid[row][column].doesMatch):
				var blockType: String = grid[row][column].blockType
				if(row >= 2 && !emptyTile(row-1,column) && grid[row-1][column].blockType == blockType and !emptyTile(row-2,column) && grid[row-2][column].blockType == blockType):
					uniqueAdd(toTreat, Vector2(row-2, column))
					uniqueAdd(toTreat, Vector2(row-1, column))
					uniqueAdd(toTreat, Vector2(row, column))
					var positions = [Vector2(row-2, column), Vector2(row-1, column), Vector2(row, column)]
					addToMatches(positions)
					thereIsAMatch = true
				if(column >= 2 && !emptyTile(row,column-1) && grid[row][column-1].blockType == blockType and !emptyTile(row,column-2) && grid[row][column-2].blockType == blockType):
					uniqueAdd(toTreat, Vector2(row, column-2))
					uniqueAdd(toTreat, Vector2(row, column-1))
					uniqueAdd(toTreat, Vector2(row, column))
					var positions = [Vector2(row, column-2), Vector2(row, column-1), Vector2(row, column)]
					addToMatches(positions)
					thereIsAMatch = true
	return thereIsAMatch

func treatBigMatches() -> void:
	for _match in matches:
		if _match[0] == 4:
			for pos in _match[1]:
				if pos in webs or pos in emptyTiles:
					_match[1].erase(pos)
			var explodingBlock: Block = firecrakerPreload.instantiate()
			var explodingTile = _match[1][randi() % _match[1].size()]
			var i:int = explodingTile.x
			var j:int = explodingTile.y
			explodingBlock.position = grid[i][j].position
			grid[i][j].nextBlock = explodingBlock
		elif _match[0] > 4:
			for pos in _match[1]:
				if pos in webs or pos in emptyTiles:
					_match[1].erase(pos)
			var moutonBlock: Block = moutonPreload.instantiate()
			var moutonTile = _match[1][randi() % _match[1].size()]
			var i:int = moutonTile.x
			var j:int = moutonTile.y
			moutonBlock.position = grid[i][j].position
			grid[i][j].nextBlock = moutonBlock
	matches = []

func deleteMatches() -> void:
	var animSignals: Array = []
	var toDelete: Array = []
	while toTreat.size() > 0:
		var pos = toTreat.pop_front()
		animSignals.append(deleteTile(pos, toDelete))

	for _signal in utils.flatten(animSignals):
		if(_signal != 'Nil'):
			await _signal

	var lastSignal: Signal
	var toShrink: Array = toDelete.duplicate()
	while toShrink.size() > 0:
		var pos = toShrink.pop_front()
		var i: int = pos.x
		var j: int = pos.y
		if pos in webs:
			var web: Web = get_node("web" + str(i) + str(j))
			lastSignal = web.shrink()
		else:
			lastSignal = grid[i][j].shrink()
	await lastSignal

	while toDelete.size() > 0:
		var pos = toDelete.pop_front()
		var i: int = pos.x
		var j: int = pos.y
		if pos in webs:
			var web: Web = get_node("web" + str(i) + str(j))
			remove_child(web)
			web.queue_free()
			webs.remove_at(webs.find(pos))
		else:
			remove_child(grid[i][j])
			grid[i][j].queue_free()
			if grid[i][j].nextBlock:
				add_child(grid[i][j].nextBlock)
				grid[i][j] = grid[i][j].nextBlock
			else:
				grid[i][j] = null
	return

func getBlocksDown2() -> void:
	var lastSignal
	for i in range(height-1,-1,-1):
		for j in width:
			if !grid[i][j] and !emptyTile(i,j):
				for k in range(i-1,-1,-1):
					if grid[k][j]:
						lastSignal = grid[k][j].move(utils.getTileCoords(Vector2(i,j), self))
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
					if Vector2(k,j) in webs or !grid[k][j].moveable:
						nbWebs +=1
						k -= 1
					else:
						var newHeight: int = k+1+nbWebs
						lastSignal = grid[k][j].move(utils.getTileCoords(Vector2(newHeight,j), self))
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
				block.position = utils.getTileCoords(Vector2(i,j), self)
				add_child(block)
				lastSignal = block.spawn()
				grid[i][j] = block
	await lastSignal

func deleteTile(pos: Vector2, toDelete: Array, triggerNeighbours: bool = true, modifyConditions: bool = true) -> Array:
	var animSignals: Array = []
	if pos in emptyTiles:
		return animSignals
	var i = pos.x
	var j = pos.y
	if pos not in toDelete:
		toDelete.push_back(pos)
		if modifyConditions:
			if Vector2(i,j) in webs:
				level.signalUpdateConditions.emit("sub", "web")
			else:
				level.signalUpdateConditions.emit("sub", grid[i][j].blockType)

	if(grid[i][j].hasTrigger):
		animSignals.append(await grid[i][j].trigger(pos, self, toDelete))
	if(triggerNeighbours):
		var neighbours = [Vector2(i, j), Vector2(i-1, j), Vector2(i+1, j), Vector2(i, j-1), Vector2(i, j+1)]
		for neighbour in neighbours:
			if(neighbour.x >= 0 and neighbour.x < height and neighbour.y >= 0 and neighbour.y < width):
				var block = grid[neighbour.x][neighbour.y]
				if(block and block.hasTrigger):
					animSignals.append(await block.trigger(neighbour, self, toDelete))
	return animSignals

func replaceBlock(pos: Vector2, block: Block) -> void:
	block.position = grid[pos.x][pos.y].position
	remove_child(grid[pos.x][pos.y])
	grid[pos.x][pos.y].queue_free()
	if(pos in webs):
		var web: Web = get_node("web" + str(pos.x) + str(pos.y))
		remove_child(web)
		web.queue_free()
		webs.remove_at(webs.find(pos))
	add_child(block)
	grid[pos.x][pos.y] = block

func getTilePositionFromCoords(coords: Vector2) -> Vector2:
	return Vector2(floor((coords.y - yStart)/offset), floor((coords.x - xStart)/offset))

func isInGrid(coords: Vector2) -> bool:
	if(coords.x < xStart or coords.x > xStart + (width*offset)
		or coords.y < yStart or coords.y > yStart + (height*offset)):
			return false
	return true
