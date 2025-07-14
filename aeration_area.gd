@tool
extends Area2D

var rng = RandomNumberGenerator.new()

func _process(_delta: float) -> void:
	pass
	


### tool code ###

func _ready() -> void:
	update_shape()

func _on_bubble_texture_rect_editor_state_changed() -> void:
	update_shape()

func _on_bubble_texture_rect_resized() -> void:
	update_shape()
func _on_bubble_texture_rect_item_rect_changed() -> void:
	update_shape()

func update_shape() -> void:
	$CollisionShape2D.shape.size = $BubbleTextureRect.size * 4
	$CollisionShape2D.position =  $BubbleTextureRect.position + ($BubbleTextureRect.size*2)
