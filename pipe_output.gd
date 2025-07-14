extends Node2D

@export var sceneToSpawn1: PackedScene
@export var sceneToSpawn2: PackedScene
@export var outputConeDegrees = 120

var rng = RandomNumberGenerator.new()




func _on_timer_timeout() -> void:
	var instance
	if rng.randf() > 0.5:
		instance = sceneToSpawn1.instantiate() # Create new instance of scene
	else:
		instance = sceneToSpawn2.instantiate() # Create new instance of scene
	instance.global_position = global_position # Position the node at the same position as this node
	
	
	instance.velocity = Vector2(100,0).rotated(rng.randf_range(-1,1))
	
	get_parent().add_child(instance) # Add the instance to the scene tree, as a sibling (not child) of this node
