class_name CropPanel
extends Control

static var seedPreload = preload("res://Scenes/seed.tscn")
const seedTextures = {
	"carrot" : [preload("res://art/Finished/Gardening/gardeningCarrot1.png"), preload("res://art/Finished/Gardening/gardeningCarrot2.png")]
}

var seedPlanted:String = "null"
var timePlanted: float = 0
var seedReady: bool = false
var seedsParams: Array = Global.seeds
var seeds: Array = []
var gardeningRectangle:GardeningRectangle = null

func _ready() -> void:
	seedPlanted = gardeningRectangle.seedPlanted
	timePlanted = gardeningRectangle.timePlanted
	$CloseButton.pressed.connect($"../".closePanel)
	for i in range(seedsParams.size()):
		var seed = seedPreload.instantiate()
		seed.position = Vector2(192 + (i%5)*54, 360 + (i/5)*54)
		seed.type = seedsParams[i]["type"]
		seed.name = seed.type
		seed.number = seedsParams[i]["number"]
		add_child(seed)
		seeds.append(seed)
	if(seedPlanted != "null"):
		var elapsedTime: float = Time.get_unix_time_from_system() - timePlanted
		if (elapsedTime > 60):
			seedReady = true
			$"Seed".texture_normal = seedTextures[seedPlanted][seedTextures[seedPlanted].size()-1]
		else:
			$"Seed".texture_normal = seedTextures[seedPlanted][0]

func spawn() -> Signal:
	self.scale = Vector2(0.1,0.1)
	var tween:Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), .3)
	return tween.finished

func plantSeed(type:String) -> void:
	if(seedPlanted != "null"):
		print("seed already planted")
	else:
		var seed:Seed = find_child(type, false,false)
		if(seed.number > 0):
			print("planting " + type + " seed")
			seedPlanted = type
			gardeningRectangle.seedPlanted = type
			seed.number -= 1
			for seedParam in seedsParams:
				if seedParam["type"] == type:
					seedParam["number"] -= 1
			$"Seed".texture_normal = seedTextures[type][0]
			timePlanted = Time.get_unix_time_from_system()
			gardeningRectangle.timePlanted = timePlanted
			$"../".saveParameters()
		else:
			print("no more seed of this type")
	pass

func gather() -> void:
	if(not seedReady):
		print("not ready yet")
		return
	else:
		for powerUp in Global.powerUps:
			if powerUp["type"] == seedPlanted:
				powerUp["number"] += 1
		$"Seed".texture_normal = null
		seedPlanted = "null"
		gardeningRectangle.seedPlanted = seedPlanted
		timePlanted = 0
		gardeningRectangle.timePlanted = timePlanted
		seedReady = false
		$"../".saveParameters()
	pass # Replace with function body.

func _on_level_button_pressed() -> void:
	var parent:LevelSelector = get_parent()
	parent.openPanel("levelPanel", {"gardeningRectangle":gardeningRectangle})
	pass
