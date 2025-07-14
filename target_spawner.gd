extends Node2D

@export var sceneToSpawn: PackedScene
@export var spawnDelay: float
var timeSinceSpawn = 0
var rng = RandomNumberGenerator.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timeSinceSpawn += delta
	if timeSinceSpawn >= spawnDelay: # Every spawnDelay seconds,
		timeSinceSpawn = 0 # Reset timer
		
		var instance = sceneToSpawn.instantiate() # Create new instance of scene
		instance.global_position = global_position # Position the node at the same position as this node
		
		instance.global_position[1] = rng.randf_range(-100, 100)
		
		get_parent().add_child(instance) # Add the instance to the scene tree, as a sibling (not child) of this node
