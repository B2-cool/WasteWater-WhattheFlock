extends Node2D

# References to the label and the timer
@onready var text_timer = $TextTimer



func _on_options_pressed():
	get_tree().change_scene_to_file("res://scenes/OptionsMenu.tscn")
