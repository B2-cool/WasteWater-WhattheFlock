extends CharacterBody2D

const gravity = -18

func _physics_process(delta: float) -> void:
	velocity -= Vector2(0,gravity*delta)
	move_and_slide()
