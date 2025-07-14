extends RigidBody2D

class_name Trash_Controller

enum DebrisType {
	SmallDebris,
	LargeDebris
}


@export var myDebrisType: DebrisType

func _ready() -> void:
	pass


func _on_button_pressed() -> void:
	queue_free()
