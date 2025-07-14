extends Sprite2D

func _process(delta: float) -> void:
	position += Vector2(0,-60) * delta
	


func _on_queue_free_timer_timeout() -> void:
	queue_free()
