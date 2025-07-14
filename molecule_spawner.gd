extends Node2D

@export var sceneToSpawn1: PackedScene
@export var spawnRate1 : int
@export var sceneToSpawn2: PackedScene
@export var spawnRate2 : int
@export var sceneToSpawn3: PackedScene
@export var spawnRate3 : int

@export var outputConeDegrees = 120

var rng = RandomNumberGenerator.new()
var spawnRateSum

func _ready() -> void:
	spawnRateSum = spawnRate1 + spawnRate2 + spawnRate3

func _on_timer_timeout() -> void:
	var instance
	var ranInt = rng.randi_range(1,spawnRateSum)
	
	if ranInt <= spawnRate1:
		instance = sceneToSpawn1.instantiate() # Create new instance of scene
	elif ranInt <= spawnRate1 + spawnRate2:
		instance = sceneToSpawn2.instantiate() # Create new instance of scene
	else:
		instance = sceneToSpawn3.instantiate() # Create new instance of scene
	
	instance.global_position = global_position # Position the node at the same position as this node
	
	instance.velocity = Vector2(375,0).rotated(rng.randf_range(-2,2))
	
	get_parent().add_child(instance) # Add the instance to the scene tree, as a sibling (not child) of this node
