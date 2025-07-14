extends Node2D

enum UVState {OFF, ON, BROKEN}
var animations = {
	UVState.OFF: "off",
	UVState.ON: "on",
	UVState.BROKEN: "broken"
}
var state: UVState = UVState.OFF

var bulbNodes: Array[Node2D] = []

# Test code – makes lights blink
var t = 0
func _process(delta):
	t += delta
	if t >= 3:
		t = 0
		toggle_lights()
		
func _ready():
	for child in get_children():
		if child is Node2D:
			bulbNodes.append(child)

func set_state(s: UVState):
	state = s
	
	for node in bulbNodes:
		node.get_node("BulbSprite").animation = animations[state]
		
		if lights_active():
			node.get_node("Glow").visible = true
		else:
			node.get_node("Glow").visible = false
		
func get_state() -> UVState:
	return state
	
func lights_active() -> bool:
	return state == UVState.ON
	
func toggle_lights():
	if state == UVState.ON: set_state(UVState.OFF)
	elif state == UVState.OFF: set_state(UVState.ON)
	
func break_lights(): set_state(UVState.BROKEN)
func fix_lights(): set_state(UVState.ON)
