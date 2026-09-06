class_name BlockSelector
extends Control

const blockTexturePaths: Dictionary = {
	"chardon": "res://art/Finished/weeds/chardon60.png",
 	"chenille": "res://art/Finished/weeds/chenille60.png",
	"egopode": "res://art/Finished/weeds/egopode60.png",
	"ortie": "res://art/Finished/weeds/ortie60.png",
	"pissenlit": "res://art/Finished/weeds/pissenlit.png",
	"morille": "res://art/Finished/weeds/morille.png",
	"web": "res://art/Finished/obstacles/Web.png",
	"firecracker": "res://art/Finished/power-ups/firecracker1.png",
	"ronce": "res://art/Finished/obstacles/ronceMoche.png",
	"lierre": "res://art/Finished/obstacles/lierreMoche.png",
	"mouton": "res://art/Finished/power-ups/mouton1.png",
	"empty": "res://art/Finished/weeds/empty.png",
	"null" : "res://art/Finished/LevelCreator/null.png"
}

@export var blockType: String

signal changeSelected(blockSelector: BlockSelector, pos:Vector2)

func toggleCadre() -> void:
	$"Cadre".visible = !$"Cadre".visible

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"BlockSelectorButton".texture_normal = load(blockTexturePaths[blockType])
	changeSelected.connect($"../../..".changeSelectedBlock)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	print("pressed")
	changeSelected.emit(self, position)
