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

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initGrid()

func initGrid() ->void:
	for i in width:
		grid.append([])
		for j in height:
			grid[i].append(null)
			
	for i in width:
		for j in height:
			var blockIndex: int = rng.randi_range(0, blocks.size()-1)
			var block = blocks[blockIndex].instantiate()
			add_child(block)
			block.position = getTileCoordsFromPosition(i,j)
	pass

func getTileCoordsFromPosition(row: int, column: int) -> Vector2:
	var xCoord: int = xStart + (column*offset)
	var yCoord: int = yStart + (row*offset)
	return Vector2(xCoord,yCoord)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
