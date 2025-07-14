extends Node2D

signal sell_sludge(amt: float)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func addSludge(amt: float):
	return $"Digester Body".addSludge(amt)


func _on_digester_body_sell_sludge(amt: float) -> void:
	emit_signal("sell_sludge", amt)
	pass # Replace with function body.
