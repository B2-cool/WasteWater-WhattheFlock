@tool
extends Area2D

## Default direction, in degrees
@export var direction1 : float = 90.0


## Alternate direction, in degrees
@export var direction2 : float = 180.0


@onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	$Arrow1.position = Vector2(64,0).rotated((direction1* PI) / 180)
	$Arrow1.rotation = (direction1* PI) / 180 
	resizeArrow($ProbSlider.value,$Arrow1)
	
	$Arrow2.position = Vector2(64,0).rotated((direction2* PI) / 180)
	$Arrow2.rotation = (direction2* PI) / 180 
	resizeArrow($ProbSlider.value,$Arrow2)
	
func resizeArrow(val,arrow):
	var x = val
	
	if arrow == $Arrow1:
		x = 1 - val
	
	if x == 0:
		arrow.scale = Vector2.ZERO
	else:
		arrow.scale = Vector2(1,1) * ((0.15 * x) + 0.125)
	
# Angles the body in a random direction.
func _on_body_entered(body: Node2D) -> void:
	var direc : float
	if rng.randf() < $ProbSlider.value:
		direc = direction2
	else:
		direc = direction1
		
	body.velocity = body.velocity.length() * Vector2.from_angle((direc*PI)/180)


func _on_prob_slider_value_changed(value: float) -> void:
	resizeArrow(value,$Arrow1)
	resizeArrow(value,$Arrow2)
