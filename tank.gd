extends Area2D

@onready var tankHeight : float = $CollisionShape2D.shape.size[0]
@onready var tankWidth : float = $CollisionShape2D.shape.size[1]
@onready var tankArea : float = tankHeight * tankWidth

@export var inputPerSecond : float = 20000
@export var OutputPerSecond : float = 20000

@onready var waterSpeed : float = 40000 / (tankArea / inputPerSecond)

enum directions {UP,DOWN,LEFT,RIGHT}

@export var flowDirection : directions = directions.RIGHT

## Maps direction name to Vector2.
var flowDirectionMap : Dictionary = {
	directions.UP:Vector2(0,-1),
	directions.DOWN:Vector2(0,1),
	directions.LEFT:Vector2(-1,0),
	directions.RIGHT:Vector2(1,0)
	}

## Normalized vector in which direction the water is flowing.
@onready var flowVector : Vector2 = flowDirectionMap[flowDirection]



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in self.get_overlapping_bodies():
		# Push bodies
		if i.is_in_group("pushedByWater"):
			i.velocity += flowVector * delta * waterSpeed/100
		# Push contaminants, limiting speed and slowing them down if they are above the max speed.
		elif i.is_in_group("movesWithWater"):
			i.velocity += (flowVector * delta * waterSpeed/100)
			if i.velocity.length() > waterSpeed/50:
				
				if i.velocity.length()-20 > waterSpeed/50:
					i.velocity = i.velocity.limit_length(i.velocity.length()-20)
				else:
					i.velocity = i.velocity.limit_length(waterSpeed/50)
