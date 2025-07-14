extends CharacterBody2D
class_name baseMolecule

@export var health = 1

@export var dropsOnDeath : PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Function that determines whether molecule can be damaged. Overwritten by children if needed.
func canBeDamaged():
	return true

func _physics_process(_delta: float) -> void:
	move_and_slide()

## Takes specified amount of damage and play hurt+flash animations. If health is 0 or lower, dies. Otherwise, invincibility frames, and check for another hit at the end.
func takeDamage(damage: float) -> void:
	health -= damage
	$MoleculeSpriteComponent.damageAnimation()
	
	if health <= 0:
		$CollisionShape2D.set_deferred("disabled",true)
		await get_tree().create_timer(1).timeout
		queue_free()
		
		if dropsOnDeath:
			var instance = dropsOnDeath.instantiate() # Create new instance of scene
			instance.global_position = global_position # Position the node at the same position as this node
			# This allows for non-CharacterBody2Ds to be dropped on death, like nitrogen gas from nitrate.
			if instance.is_class("CharacterBody2D"):
				
				instance.velocity = velocity
			get_parent().add_child(instance) # Add the instance to the scene tree, as a sibling (not child) of this node


# Decrease health when hit.
func tryDamage(damage: float) -> bool:
	if canBeDamaged():
		takeDamage(damage)
		return true
	else:
		$MoleculeSpriteComponent.invincibleAnimation()
		return false
