extends Node2D

@onready var screensArray = $SCREENS.get_children()
@onready var pause_menu = $PlayerView/PauseMenu

var currentScreenIndex: int = 2
var paused: bool = false
var screen_pending: int = -1

signal onCameraChange(screen: int)

func _ready() -> void:
	if screensArray.size() > 2:
		_set_screen(2)
	else:
		print("Not enough screens to set the initial screen.")
	pause_menu.hide()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		_toggle_pause()

	# Apply queued screen switch after unpause
	if not paused and screen_pending != -1:
		_set_screen(screen_pending)
		screen_pending = -1

func _input(event: InputEvent) -> void:
	for i in range(1, 10):
		if event.is_action_pressed(str(i)) and screensArray.size() >= i:
			if paused:
				screen_pending = i - 1
				print("Screen switch queued to:", i - 1)
			else:
				_set_screen(i - 1)

# Switch to the selected screen
func _set_screen(screen_index: int) -> void:
	if screen_index >= 0 and screen_index < screensArray.size():
		currentScreenIndex = screen_index
		$PlayerView.TweenCameraToScreen(screensArray[currentScreenIndex])
		onCameraChange.emit(currentScreenIndex)
	else:
		print("Invalid screen index: ", screen_index)

# Toggle pause menu and slow down time
func _toggle_pause() -> void:
	paused = !paused
	pause_menu.visible = paused
	Engine.time_scale = 0 if paused else 1
