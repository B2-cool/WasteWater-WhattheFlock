extends Node

@export var lifetimeSec: float # Despawn object after this many seconds
var lifetime = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	lifetime += delta
	if lifetime >= lifetimeSec:
		queue_free()
