extends Node2D

## When the membrane is right-clicked (floc sticky area, which is most of the membrane, is right-clicked),
## delete the membrane and allow a new one to be placed
func _on_floc_sticky_area_input_event(viewport, event, shape_idx):
	# If this is a mouse click,
	if event is InputEventMouseButton and event.pressed:
		# and it's a left-click,
		if event.button_index == MOUSE_BUTTON_RIGHT:
			# Find cannon node and allow a new membrane to be placed
			$"../Cannon".ammoMembrane += 1
			
			# Delete the membrane
			queue_free()
