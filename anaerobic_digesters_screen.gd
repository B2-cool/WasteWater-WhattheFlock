extends Node2D

@export var digestersY: float
@export var digestersX: float
@export var addSludgeAmount: float
var digesters = []

var digesterScene = load("res://scenes/anaerobic digestion/anaerobic_digester.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	addDigester()
	addDigester()
	addDigester()
	addDigester()
	pass # Replace with function body.


func addSludge(amt: float):
	var amount = amt
	for digester in digesters:
		amount = digester.addSludge(amount)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func addDigester():
	print("digester added")
	var digester = digesterScene.instantiate()
	digester.position = Vector2(digestersX, digestersY)
	digester.sell_sludge.connect(_on_sell_sludge)
	digestersX += 192
	add_child(digester)
	digesters.append(digester)


func _on_return_sludge_screen_add_sludge() -> void:
	addSludge(addSludgeAmount)

func _on_sell_sludge(amt: float):
	GlobalTime.add_money(amt)
	$TruckAnimation.play()
