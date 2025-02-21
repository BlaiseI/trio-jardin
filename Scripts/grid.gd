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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initGrid()

func initGrid() -> void:
	for i in width:
		grid.append([])
		for j in height:
			grid[i].append(null)
			var cadre = cadrePreload.instantiate()
			add_child(cadre)
			cadre.position = getTileCoordsFromPosition(i,j)
	for i in width:
		for j in height:
			var isMatch: bool = true
			var block
			while(isMatch):
				var blockIndex: int = rng.randi_range(0, blocks.size()-1)
				block = blocks[blockIndex].instantiate()
				if not givesMatch(j,i,block) :
					isMatch = false
			add_child(block)
			block.position = getTileCoordsFromPosition(i,j)
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

func getTileCoordsFromPosition(row: int, column: int) -> Vector2:
	var xCoord: int = xStart + (column*offset)
	var yCoord: int = yStart + (row*offset)
	return Vector2(xCoord,yCoord)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
