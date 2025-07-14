extends Area2D

## How fast the target moves around, in pixels per second
@export var speed: float
var velocity: Vector2

## Despawn this node once it's been alive for this long
@export var despawnTime: float
var lifetime = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var angle = randf() * 2 * PI
	velocity = Vector2(cos(angle), sin(angle)) * speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta
	lifetime += delta
	if lifetime >= despawnTime: queue_free() # Despawn this node after despawnTime seconds

func _on_body_entered(body): # Whenever a colliding body enters the area,
	if body.is_in_group("test_cannon_shot"): # if it was a cannon shot,
		queue_free() # despawn this node
		
