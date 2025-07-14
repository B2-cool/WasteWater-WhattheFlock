extends CharacterBody2D
class_name Floc

const gravity : float = -18

@export var spawnOnDeath : PackedScene

var mitosisScene : PackedScene = load("res://scenes/cannon scenes/floc.tscn")

## Decreases 1 every second. Floc dies if it reaches 0. Increases through eating molecules. Higher energy increases acceleration.
@export var energy : int = 5
## Maximum energy for this floc.
@export var maxEnergy : int = 15
## Energy level that floc will reach before splitting in two.
@export var mitosisEnergy : int = 10

## Decreases 1 every second. Floc dies if it reaches 0. Cannot be increased.
@export var lifespan : int = 20
## Multiplies acceleration.
@export var accelerationMultiplier : float = 1.0
## Maximum speed the floc can travel at.
@export var maxSpeed : float = 200.0
## How long it takes a floc to eat molecules, in seconds. 
@export var nomTime : float = 1


var isNomming : bool = false

# If stuckToParent is true. this floc is stuck to something. Stop in place and do not move until despawning
var stuckToParent = false

## Velocity from the cannot shot. Tracked seperatly from velocity so the initial velocity from the cannon is not limited by the floc's max speed.
var cannonVelocity : Vector2 = Vector2(0,0)
## Which contaminant a floc is currently heading towards.
var headingTo : CharacterBody2D = null

@onready var audio: FlocSfxPlayer = $FlocSfxPlayer


# Selects a random flock animation when spawned.
func _ready() -> void:
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()
	$AnimatedSprite2D.sprite_frames = load("res://scenes/cannon scenes/floc" + str(rng.randi_range(1,3)) + ".tres")
	$AnimatedSprite2D.play("idle")

func _physics_process(delta: float) -> void:
	# Decrease cannon velocity.
	if cannonVelocity != Vector2(0,0):
		cannonVelocity = cannonVelocity.limit_length(cannonVelocity.length()-delta*200)
		if cannonVelocity.length() < 1:
			cannonVelocity = Vector2(0,0)
	
	# Head towards nearest contaminant (if it is detected).
	headingTo = get_closest_contaminant()
	if headingTo != null:
		velocity += (headingTo.position - position).normalized() * energy * accelerationMultiplier
	
	# Limit velocity by maxSpeed.
	velocity = velocity.limit_length(maxSpeed)
	
	# Gravity.
	velocity -= Vector2(0,gravity*delta)
	
	# Move floc, and bounce off walls if needed.
	if not stuckToParent:
		var collision = move_and_collide((velocity + cannonVelocity)*delta)
		if collision:
			velocity = velocity.bounce(collision.get_normal()) * 0.5
			cannonVelocity = cannonVelocity.bounce(collision.get_normal()) * 0.5

## If a floc is currently in aeration areas.
func inAeration() -> bool:
	for area in $HitBox.get_overlapping_areas():
		if area.is_in_group("aeration"):
			return true
	return false

## Finds the closest contaminant to the floc within its search radius. Returns null if none are found.
func get_closest_contaminant() -> CharacterBody2D:
	if $SearchBox.monitoring == false:
		return null
		
	var enemiesInView = $SearchBox.get_overlapping_bodies()
	
	if enemiesInView.size() < 1:
		return null
		
	var closestEnemy = null
	
	for enemy in enemiesInView:
		if enemy.is_in_group("contaminant"):
			if closestEnemy == null:
				closestEnemy = enemy
			if position.distance_to(enemy.position) < position.distance_to(closestEnemy.position):
				closestEnemy = enemy
			
	return closestEnemy

# Lifespan and energy tics.
func _on_timer_timeout() -> void:
	energy -= 1
	lifespan -=1
	
	if energy <= 0 or lifespan <= 0:
		die()
	# If there is enough energy, cut energy in half and mitosis.
	if energy >= mitosisEnergy:

		energy = roundi(float(energy)/2)

		var baby = mitosisScene.instantiate()
		baby.global_position = global_position
		baby.energy = energy
		baby.scale = scale
		get_parent().add_child(baby)
		audio.play_grow_sound()
		
	
	# Scale speed based on energy
	$AnimatedSprite2D.speed_scale = 0.5 + (float(energy) * 2/float(maxEnergy))

# Gains energy when hitting a contaminant, and stops searching for a second.
func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("contaminant") and !isNomming:
		
		var moleculeDamaged : bool = body.tryDamage(1)
		
		if moleculeDamaged:
			isNomming = true
			$AnimatedSprite2D.play("eat")
			var thisNomTime = nomTime
			if inAeration():
				thisNomTime = nomTime / 2
			audio.play_eat_sound()
			await get_tree().create_timer(thisNomTime).timeout
			headingTo = null
			energy = min(energy+1, maxEnergy)
			isNomming = false
			$AnimatedSprite2D.play("idle")
			if $HitBox.get_overlapping_bodies().size() > 0:
				_on_hit_box_body_entered($HitBox.get_overlapping_bodies()[0])

# Hit a membrane or an IFAS, freeze in place, and set self to be a child of that object so it will follow it around (if the object is an IFAS)
func notify_hit_sticky_object(obj: Node2D):
	stuckToParent = true
	$StickyBox.free() # Prevent this floc from later sticking to something else (simply setting monitorable to false doesn't work, because that doesn't take effect until next frame. Likewise, queue_free() doesn't work.)
	
	var pos = global_position # Preserve global position for after parent change
	get_parent().remove_child(self)
	obj.call_deferred("add_child", self)
	call_deferred("update_global_pos", pos)

func update_global_pos(pos):
	global_position = pos

func die() -> void:
	var newScene = spawnOnDeath.instantiate()
	
	var parent = get_parent()
	# If this floc is stuck to something, we don't want the death scene to spawn as a child of that object, but as a child of the main scene instead.
	if stuckToParent: parent = parent.get_parent().get_parent() # Get the FlocStickyArea that this is stuck to, then the object it's part of, then finally the root scene
	parent.add_child(newScene)
	
	# Don't set global_position until after figuring out parent node
	newScene.global_position = self.global_position
	newScene.velocity = self.velocity
	
	queue_free()
