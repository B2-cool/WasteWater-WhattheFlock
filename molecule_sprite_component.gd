extends Sprite2D

const animations = ['A','B','C','D','E','F']
@export var states = 4

func _ready() -> void:
	self.set_hframes(states)

@onready var i = 0

func damageAnimation():
	if i < states:
		i += 1
		$AnimationPlayer.play(animations[i])

func invincibleAnimation():
	$AnimationPlayer.play("invincible")
