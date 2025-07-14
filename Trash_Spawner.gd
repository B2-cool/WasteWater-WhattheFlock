extends Node2D

@export var isSpawning = false
@export var SpawnArea: Area2D
@export var ScenesToSpawn: Array[PackedScene]
@export var spawnInterval: float = 2
var RNG = RandomNumberGenerator.new()
var SpawnPosition : Vector2
var timer = spawnInterval

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	var collisionObject = SpawnArea.get_node("CollisionShape2D")
	var centerPosition = collisionObject.position + SpawnArea.position
	var size = collisionObject.shape.get_size()
	
	#Spawns a the scene within the Trashspwanners collider.
	if isSpawning && timer > spawnInterval:
		timer = 0
		SpawnPosition.x = (randi() % int(size.x)) - (size.x/2) + centerPosition.x
		SpawnPosition.y = (randi() % int(size.y)) - (size.y/2) + centerPosition.y	
		var spawn = ScenesToSpawn[RNG.randi_range(0,ScenesToSpawn.size() - 1)].instantiate()
		spawn.position = SpawnPosition
		add_child(spawn)
	

func _input(ev):
	if Input.is_key_pressed(KEY_T):
		if isSpawning:
			isSpawning = false
		else:
			isSpawning = true
