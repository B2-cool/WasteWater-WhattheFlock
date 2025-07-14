extends CanvasLayer

@onready var ui_CityName: Label = get_node("Container/HBox/CityName")
@onready var ui_Approval: Label = get_node("Container/HBox/Approval")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize the UI elements with the global variables
	ui_CityName.text = Global.cityName
	ui_Approval.text = "Approval: " + str(Global.approval)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
