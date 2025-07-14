extends Node2D

@export var strength : int = 180

@export var ignoreContaminants: bool

enum directions {UP,DOWN,LEFT,RIGHT}

@export var suckDirection : directions = directions.RIGHT

## Maps direction name to Vector2.
var suckDirectionMap : Dictionary = {
	directions.UP:Vector2(0,-1),
	directions.DOWN:Vector2(0,1),
	directions.LEFT:Vector2(-1,0),
	directions.RIGHT:Vector2(1,0)
	}

## Normalized vector in which direction the water is flowing.
@onready var suckVector : Vector2 = suckDirectionMap[suckDirection]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for body in $Area2D.get_overlapping_bodies():
		# If this suction pipe does not affect contaminants, ignore any of them that overlap
		if ignoreContaminants and body.is_in_group("contaminant"):
			continue
		
		if body.global_position * suckVector < self.global_position * suckVector:
			body.velocity += (self.global_position - body.global_position).normalized() * strength * delta
