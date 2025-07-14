extends Node2D

@export var capacity: float
@export var big: bool
@export var smallBarHeight: float
@export var bigBarHeight: float
@export var smallBarOffset: int
@export var bigBarOffset: int
var amountHeld: float = 0
signal sell_sludge(amt: float)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	$"Big Digester Animation".visible = big
	$"Small Digester Animation".visible = !big
	queue_redraw()
	pass


func _draw():
	var fillAmount = amountHeld / capacity
	var col
	var offset
	if(fillAmount < 0.4):
		col = Color("8e8f5e");
	elif(fillAmount < 0.8):
		col = Color("f49b57");
	else:
		col = Color("cd283b");
	if(big):
		fillAmount *= bigBarHeight
		offset = bigBarOffset
	else:
		fillAmount *= smallBarHeight
		offset = smallBarOffset
	draw_rect(Rect2(-4.0, offset-4*floor(fillAmount), 8.0, 4*floor(fillAmount)), col);

func upgradeDigester():
	if(!big):
		big = true

func addSludge(amt: float):
	amountHeld = amountHeld + amt
	if(amountHeld > capacity):
		var extra = amountHeld - capacity
		amountHeld = capacity
		return extra
	return 0


func _on_sell_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if(!event.is_action_pressed("cannon_fire")):
		return
	if(amountHeld < capacity):
		return
	amountHeld = 0
	emit_signal("sell_sludge", capacity)
	
