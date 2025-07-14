extends Sprite2D

@onready var MyCamera = $Camera2D
@export var currentScreen = 0
@export var cameraLockingOn = false

const CAMERA_MOVEMENT_SPEED: float = 10
const CAMERA_ZOOM_SPEED: Vector2 = Vector2(0.3, 0.3)
const CAMERA_ZOOM_DEFAULT: Vector2 = Vector2(1.0, 1.0)
const CAMERA_ZOOM_MIN: Vector2 = Vector2(0.25, 0.25)
const CAMERA_ZOOM_MAX: Vector2 = Vector2(1.0, 1.0)
const CAMERA_TWEEN_DURATION: float = 0.5

const leftLimit = -2500
const rightLimit = 2700

var m_CameraTween: Tween = null

func _physics_process(_delta: float) -> void:
	if !cameraLockingOn:
		if Input.is_action_pressed('view_left'):
			position.x -= 32
			if position.x < leftLimit:
				position.x = leftLimit
		if Input.is_action_pressed('view_right'):
			position.x += 32
			if position.x > rightLimit:
				position.x = rightLimit

func TweenCameraToScreen(nod) -> void:
	# If a screen is not a texture rect, look it see if it has a texture rect child. If it does, assign screen to the first one. otherwise, return.
	var screen
	if (is_instance_of(nod,TextureRect)):
		screen = nod
	else:
		var nodTextureRectChildren = nod.get_children().filter(func(child): return is_instance_of(child, TextureRect))
		if nodTextureRectChildren.size() < 1:
			return
		screen = nodTextureRectChildren[0]
	var x = nod.position.x + screen.position.x + screen.size.x / 2
	var y = nod.position.y + screen.position.y + screen.size.y / 2
	
	TweenCamera(Vector2(x, y))

func TweenCamera(pos: Vector2):
	cameraLockingOn = true
	# var x = pos.x + 432
	# var y = pos.y + 324
	if m_CameraTween and m_CameraTween.is_running():
		m_CameraTween.kill()
	if m_CameraTween == null or not m_CameraTween.is_running():
		m_CameraTween = MyCamera.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
		m_CameraTween.tween_property(self, "position", pos, CAMERA_TWEEN_DURATION)
		m_CameraTween.play()
	await m_CameraTween.finished
	cameraLockingOn = false

func _input(event) -> void:
	if !cameraLockingOn:
		if event.is_action_pressed("mouse_wheel_up"):
			var new_zoom = MyCamera.zoom + Vector2(0.10, 0.10)
			if new_zoom > CAMERA_ZOOM_MAX:
				new_zoom = CAMERA_ZOOM_MAX
			TweenCameraZoom(new_zoom)
		if event.is_action_pressed("mouse_wheel_down"):
			var new_zoom = MyCamera.zoom - Vector2(0.10, 0.10)
			if new_zoom < CAMERA_ZOOM_MIN:
				new_zoom = CAMERA_ZOOM_MIN
			TweenCameraZoom(new_zoom)
	

func TweenCameraZoom(new_zoom: Vector2):
	if m_CameraTween and m_CameraTween.is_running():
		m_CameraTween.kill()
	m_CameraTween = MyCamera.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART).set_parallel(true)
	m_CameraTween.tween_property(MyCamera, "zoom", new_zoom, CAMERA_TWEEN_DURATION)
	m_CameraTween.play()
