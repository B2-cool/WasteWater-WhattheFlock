extends Area2D

enum state {SHRINK, GROW}

@export var behavior = state.SHRINK 

func _on_body_entered(body: Node2D) -> void:
	var tween = get_tree().create_tween()
	if behavior == state.SHRINK:
		tween.tween_property(body, "scale", Vector2(), 0.5)
	else:
		tween.tween_property(body, "scale", Vector2(1,1), 0.5)
