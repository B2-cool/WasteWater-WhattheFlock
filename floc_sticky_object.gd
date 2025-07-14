extends Area2D

func _on_area_entered(area):
	var body = area.get_parent()
	if body.is_in_group("floc") and area.name == "StickyBox":
		var floc = body as Floc
		floc.notify_hit_sticky_object(self)
