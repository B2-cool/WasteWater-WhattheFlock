extends Node2D

@export var lifetime: float
var timeLived = 0

@export var damage: float ## Damage dealth by this disinfectant cloud per tick

@export var damageTimeSec: float ## Damage overlapping contaminants every this many seconds
var timeSinceDamage = 0

@onready var hitbox = $Hitbox

func _process(delta):
	timeLived += delta
	if timeLived >= lifetime:
		queue_free()

	timeSinceDamage += delta
	if timeSinceDamage >= damageTimeSec:
		timeSinceDamage = 0
		for body in hitbox.get_overlapping_bodies():
			if body.is_in_group("contaminant"):
				body.tryDamage(damage)
