extends CharacterBody2D

const gravity : float = 0.0

## Decreases 1 every second. Floc dies if it reaches 0. Cannot be increased.
@export var lifespan : int = 20

## Velocity from the cannot shot. Tracked seperatly from velocity so the initial velocity from the cannon is not limited by the floc's max speed.
var cannonVelocity : Vector2 = Vector2(0,0)



func _physics_process(delta: float) -> void:
	# Move floc, and bounce off walls if needed.
	var collision = move_and_collide((velocity + cannonVelocity)*delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		cannonVelocity = cannonVelocity.bounce(collision.get_normal())

# Lifespan and energy tics.
func _on_timer_timeout() -> void:
	lifespan -=1
	
	if lifespan <= 0:
		for child in $FlocStickyArea.get_children():
			if child.is_in_group("floc"):
				print("test")
				(child as Floc).die() # Ensure that flocs die and spawn dead floc instances, instead of vanishing forever
		
		queue_free()
