extends Area2D

@export var ammo : PackedScene

var justPressed : bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("sludge"):
		var newAmmo = ammo.instantiate()
		newAmmo.global_position = body.global_position
		newAmmo.velocity = body.velocity
		get_tree().root.call_deferred("add_child",newAmmo)

func _on_body_exited(_body: Node2D) -> void:
	if get_overlapping_bodies().size() < 5:
		$Button.visible = true


func _on_button_pressed() -> void:
	justPressed = true
	for i in range(5):
		var newAmmo = ammo.instantiate()
		# spaces out the ammo so they dont collide and explode
		newAmmo.global_position = $EmergencySpawnPos.global_position + Vector2(80*i,0)
		newAmmo.velocity = Vector2(0,0)
		get_tree().root.call_deferred("add_child",newAmmo)
	$Button.visible = false
	await get_tree().create_timer(0.1).timeout
	justPressed = false
