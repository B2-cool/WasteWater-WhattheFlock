extends Node2D



## The rectangle in which clicks cause the cannon to fire
# Note: These are in GLOBAL coordinates!
@export var chlorineRectMin: Vector2 ## top left corner of chlorine placement click area
@export var chlorineRectMax: Vector2 ## bottom right corner of chlorine placement click area
@export var ozoneRectMin: Vector2 ## top left corner of ozone placement click area
@export var ozoneRectMax: Vector2 ## bottom right corner of ozone placement click area

@export var chlorineScene: PackedScene
@export var ozoneScene: PackedScene

@export var maxChlorine: float
@onready var chlorine = maxChlorine
@export var maxOzone: float
@onready var ozone = maxOzone

@export var uvDamageTimeSec: float ## How often UV lights damage phages
var timeSinceUVDamage = 0
@onready var uvArea = $UVArea
@export var uvDamage: float ## Damage done by UV lights per tick

var uvOn: bool = false

@onready var barCl = $ClBar
@onready var barO3 = $O3Bar
@onready var uvLights = $UVLights
@onready var sfxPlayer = $DisinfectantSFXPlayer

func _process(delta):
	if Input.is_action_just_pressed("disinfection_place"):
		var mousePos = get_local_mouse_position()
		if point_in_chlorine_rect(mousePos) and chlorine > 0:
			place_chlorine(mousePos)
		elif point_in_ozone_rect(mousePos) and ozone > 0:
			place_ozone(mousePos)
			
	barCl.value = barCl.max_value * (chlorine / maxChlorine)
	barO3.value = barO3.max_value * (ozone / maxOzone)
	
	timeSinceUVDamage += delta
	if timeSinceUVDamage >= uvDamageTimeSec:
		timeSinceUVDamage = 0
		if uvLights.lights_active():
			for body in uvArea.get_overlapping_bodies():
				if body.is_in_group("contaminant"):
					body.tryDamage(uvDamage)

## Check if a point (e.g. mouse global position) is inside the rectangle in which chlorine can be placed
func point_in_chlorine_rect(pt: Vector2) -> bool:
	if (pt.x >= chlorineRectMin.x and pt.y >= chlorineRectMin.y and pt.x <= chlorineRectMax.x and pt.y <= chlorineRectMax.y):
		return true
	return false
	
## Check if a point (e.g. mouse global position) is inside the rectangle in which ozone can be placed
func point_in_ozone_rect(pt: Vector2) -> bool:
	if (pt.x >= ozoneRectMin.x and pt.y >= ozoneRectMin.y and pt.x <= ozoneRectMax.x and pt.y <= ozoneRectMax.y):
		return true
	return false

func place_chlorine(mousePos):
	chlorine -= 1
	
	var instance = chlorineScene.instantiate()
	instance.global_position = mousePos
	add_child(instance)
	
func place_ozone(mousePos):
	ozone -= 1
	
	var instance = ozoneScene.instantiate()
	instance.global_position = mousePos
	add_child(instance)

# When chlorine tank clicked
func _on_cl_refill_input_event(_viewport, event, _shape_idx):
	# If this is a mouse click,
	if event is InputEventMouseButton and event.pressed:
		# and it's a left-click,
		if event.button_index == MOUSE_BUTTON_LEFT:
			chlorine = maxChlorine
			
			play_refill_sfx()

# When ozone tank clicked
func _on_o3_refill_input_event(_viewport, event, _shape_idx):
	# If this is a mouse click,
	if event is InputEventMouseButton and event.pressed:
		# and it's a left-click,
		if event.button_index == MOUSE_BUTTON_LEFT:
			ozone = maxOzone
			
			play_refill_sfx()

func play_refill_sfx():
	sfxPlayer.play()
