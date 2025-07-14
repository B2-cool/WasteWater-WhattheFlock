extends Area2D

## The amount of variation in either direction
@export var degrees : float = 45.0

@onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()

# Angles the body in a random direction.
func _on_body_entered(body: Node2D) -> void:
	var randomDir = (rng.randf_range(-degrees,degrees) * PI) / 180
	body.velocity = body.velocity.length() * Vector2.from_angle(randomDir)
