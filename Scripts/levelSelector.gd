extends Node2D

var actualLevel: int
var nbGardeningRectangles: int
var gardeningRectangles: Array = []
var gardeningRectTemplate:PackedScene = preload("res://Scenes/gardeningRect.tscn")

func saveParameters() -> void:
	var parametersDictionary: Dictionary = {
		"actualLevel":actualLevel,
		"nbGardeningRectangles":nbGardeningRectangles,
		"gardeningRectangles":[],
	}
	for gardeningRectangle : GardeningRectangle in gardeningRectangles:
		parametersDictionary["gardeningRectangles"].append(gardeningRectangle.toDict())
	DirAccess.make_dir_recursive_absolute("res://gameSave")
	var filePath: String = "res://gameSave/save.json"
	var saveFile = FileAccess.open(filePath, FileAccess.WRITE_READ)
	var parametersJSONString:String = JSON.stringify(parametersDictionary)
	saveFile.store_line(parametersJSONString)

func loadParameters(filePath: String) -> void:
	var saveFile:FileAccess = FileAccess.open(filePath, FileAccess.READ)
	var paramsJSONString = saveFile.get_line()
	var paramsJSON = JSON.new()
	paramsJSON.parse(paramsJSONString)
	var parametersDictionary: Dictionary = paramsJSON.data

	actualLevel = parametersDictionary["actualLevel"]
	nbGardeningRectangles = parametersDictionary["nbGardeningRectangles"]
	for gardeningRectangleDict: Dictionary in parametersDictionary["gardeningRectangles"]:
		gardeningRectangles.append(GardeningRectangle.fromDict(gardeningRectangleDict))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadParameters("res://gameSave/save.json")
	for gardeningRectangle: GardeningRectangle in gardeningRectangles:
		var gardeningRect: Node2D = gardeningRectTemplate.instantiate()
		gardeningRect.position = gardeningRectangle.position
		gardeningRectangle.node = gardeningRect
		add_child(gardeningRect)

	#saveParameters()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_released("ui_touch"):
	#	var touchCoords: Vector2 = get_global_mouse_position()
	pass

class GardeningRectangle:
	var id: int
	var position: Vector2
	var active: bool
	var firstLevel: int
	var nbLevels: int
	var node: Node2D

	func _init(id: int, position: Vector2, active: bool, firstLevel: int, nbLevels:int):
		self.id = id;
		self.position = position;
		self.active = active;
		self.firstLevel = firstLevel;
		self.nbLevels = nbLevels;

	func toDict() -> Dictionary:
		print(id)
		return {
			"id": id,
			"position": position,
			"active": active,
			"firstLevel": firstLevel,
			"nbLevels": nbLevels
		}

	static func fromDict(parametersDictionary: Dictionary) -> GardeningRectangle:
		return GardeningRectangle.new(
			parametersDictionary["id"],
			str_to_var("Vector2" + parametersDictionary["position"]),
			parametersDictionary["active"],
			parametersDictionary["firstLevel"],
			parametersDictionary["nbLevels"],
		)
