extends Node2D

## The point around which the cannon body rotates. We rotate the cannon by making the cannon body a child node of the rotation point, and then rotating the rotation point.
@onready var rotatePt = $"RotatePt"
## The point at which shot scenes are instanced. The direction of the shot can be calculated by (firePt.global_position - rotatePt.global_position), since rotatePt is at the base of the cannon and firePt is at the end.
@onready var firePt = $"RotatePt/FirePt"

## The object to fire from the cannon.
@export var flocScene: PackedScene
@export var ifasScene: PackedScene
@export var membraneScene: PackedScene
## Initial speed of shots upon firing
@export var shotSpeed: float

## Side-to-side speed of the cannon
@export var moveAcceleration: float
@export var friction: float
var velocity = Vector2.ZERO
@export var minXPosition: float
@export var maxXPosition: float

## Rotation speed of the cannon
@export var rotateSpeed: float
## The minimum and maximum rotation of rotatePt, in radians. 0 is directly up.
@export var minRotation: float
@export var maxRotation: float

## The rectangle in which clicks cause the cannon to fire
# Note: These are in GLOBAL coordinates!
@export var fireRectMin: Vector2 ## top left corner of cannon fire click area
@export var fireRectMax: Vector2 ## bottom right corner of cannon fire click area

# Minimum time in between subsequent cannon shots
@export var fireDelaySec_floc: float
@export var fireDelaySec_ifas: float
var timeSinceFire = 0 # Timer since last shot fired

## If the player is in floc mode, and holds down the mouse for this long, the cannon will shoot a burst of several flocs all at once.
@export var multiShotHoldDelaySec: float
var mouseHeldTime = 0
## When the player fires a burst, how many shots are included
@export var multiShotFireCount: int
## The angle at which the burst shot flocs are spread over, in radians.
@export var burstShotSpreadAngle: float
## After a burst is fired, this is set to true, and the next mouse release will set this to false instead of firing.
var burstJustFired: bool = false

## The Y-coordinate of the base of the tank, since membrane bases should be level with this
@export var membraneBaseYCoordinate: float
@export var membraneXMin: float
@export var membraneXMax: float

# What the cannon is currently firing.
# FLOC: Firing microbe flocs, single or burst fire.
# IFAS: Firing IFAS scaffolding pieces.
# MEMBRANE: Not firing at all, but rather letting the player click to place a membrane piece
# NONE: Unused, could be useful later to prevent the player from shooting during e.g. a tutorial section
enum FireMode {NONE, FLOC, IFAS, MEMBRANE}
var fireMode = FireMode.FLOC

# In player mode, the player aims and fires the cannon with point-and-click.
# In auto mode, the cannon automatically targets and shoots at the nearest sibling node in group "test_target".
enum ControlMode {PLAYER, AUTO_SIMPLE, AUTO_ADVANCED}
var AUTO_CONTROL_MODES = [ControlMode.AUTO_SIMPLE, ControlMode.AUTO_ADVANCED]
var controlMode = ControlMode.PLAYER
@export var reacquireTargetSec: float ## Re-check for closest target every so often
var timeSinceTargetCheck = 0
var currentAutoTarget: Node2D = null # null when no target has been acquired

@onready var audio: CannonSfxPlayer = $CannonSfxPlayer

@onready var membranePlacementGhost = $"MembranePlacementGhost"

@export var ammoMembrane = 3
@export var ammoIFAS = 3

var canFire = true

# prevents the ammo area from moving with the cannon, while still putting it in the correct location.
func _ready() -> void:
	$AmmoArea.top_level = true
	$AmmoArea.global_position += global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# If the player is not allowed to fire, don't do anything
	if !canFire:
		return
	
	check_mode_inputs()
	
	# If in membrane placement mode, show membrane ghost and check whether to place a membrane
	if fireMode == FireMode.MEMBRANE  and ammoMembrane > 0:
		var mouseCoords = get_global_mouse_position()
		
		if mouseCoords.x >= membraneXMin and mouseCoords.x <= membraneXMax:
			membranePlacementGhost.show()
			membranePlacementGhost.global_position = mouseCoords
			membranePlacementGhost.global_position.y = membraneBaseYCoordinate
		
			if Input.is_action_just_pressed("cannon_fire"):
				place_membrane()
				
		else:
			# Mouse is outside valid placement area for membranes, so hide the ghost
			membranePlacementGhost.hide()
	else:
		membranePlacementGhost.hide()
	
	# Update shot cooldown timer, if it hasn't been long enough to fire again
	if timeSinceFire < fireDelaySec_floc or timeSinceFire < fireDelaySec_ifas: timeSinceFire += delta
	
	if timeSinceTargetCheck < reacquireTargetSec: timeSinceTargetCheck += delta
	
	# Update burst shot timer, if mouse button is held down
	if fireMode == FireMode.FLOC and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		$RotatePt/Sprite2D/AnimationPlayer.play("chargeCannon")
		mouseHeldTime += delta
		if mouseHeldTime >= multiShotHoldDelaySec and ammoInAmmoArea() >= 2:
			mouseHeldTime = 0
			burstJustFired = true
			fire_burst(multiShotFireCount)
			$RotatePt/Sprite2D/AnimationPlayer.play("RESET")
	else:
		mouseHeldTime = 0
		$RotatePt/Sprite2D/AnimationPlayer.play("RESET")
	
	# Fire cannon
	if fireMode == FireMode.FLOC and timeSinceFire >= fireDelaySec_floc and ammoInAmmoArea() and !$AmmoArea.justPressed:
		if controlMode == ControlMode.PLAYER and Input.is_action_just_released("cannon_fire") and mouse_in_fire_rect():
			if burstJustFired:
				burstJustFired = false
			else:
				fire_floc()
		elif controlMode in AUTO_CONTROL_MODES and currentAutoTarget != null:
			fire_floc()
	elif fireMode == FireMode.IFAS and timeSinceFire >= fireDelaySec_ifas and ammoIFAS > 0:
		# IFAS cannot be auto-fired!
		if controlMode == ControlMode.PLAYER and Input.is_action_just_released("cannon_fire"):
			fire_ifas()
	
	# Handle cannon rotation
	if controlMode == ControlMode.PLAYER:
		# Rotate the cannon to face the mouse pointer
		var mousePos = get_local_mouse_position() # Get the mouse position *relative to this node* -- very convenient that Godot has this :)
		var angleToMouse = atan2(mousePos.y, mousePos.x) # Calculate the angle towards the mouse position, using signed arctangent
		if angleToMouse > PI / 2: angleToMouse -= 2 * PI # Change domain of angle from (-2pi,2pi) to (-3pi/2,5pi/2). This way, the sudden "jump" in angle values happens at straight down, not to the right. Thus any snapping of the angle will happen as the mouse moves underneath , rather than as the mouse moves lower than the cannon by height. This feels much more natural.
		rotatePt.rotation = angleToMouse
	elif controlMode == ControlMode.AUTO_SIMPLE:
		if currentAutoTarget != null:
			var vecToTarget = currentAutoTarget.global_position - global_position
			var angleToTarget = atan2(vecToTarget.y, vecToTarget.x)
			if angleToTarget > PI / 2: angleToTarget -= 2 * PI # Stay consistent with mouse angles
			
			if rotatePt.rotation > angleToTarget:
				rotatePt.rotation -= rotateSpeed * delta
			elif rotatePt.rotation < angleToTarget:
				rotatePt.rotation += rotateSpeed * delta
		
		if currentAutoTarget == null or timeSinceTargetCheck >= reacquireTargetSec:
			reacquire_target()
	elif controlMode == ControlMode.AUTO_ADVANCED:
		# Acquire a target if none is found yet
		if currentAutoTarget == null or timeSinceTargetCheck >= reacquireTargetSec:
			reacquire_target()

		if currentAutoTarget != null:
			var vecToTarget = currentAutoTarget.global_position - global_position
			var angleToTarget = atan2(vecToTarget.y, vecToTarget.x) # Calculate the angle towards the mouse position, using signed arctangent
			if angleToTarget > PI / 2: angleToTarget -= 2 * PI # Change domain of angle from (-2pi,2pi) to (-3pi/2,5pi/2). This way, the sudden "jump" in angle values happens at straight down, not to the right. Thus any snapping of the angle will happen as the mouse moves underneath , rather than as the mouse moves lower than the cannon by height. This feels much more natural.
			rotatePt.rotation = angleToTarget
	
	# Keep the rotation between minRotation and maxRotation
	rotatePt.rotation = clamp(rotatePt.rotation, minRotation, maxRotation)

	if controlMode == ControlMode.PLAYER:
		# Move cannon horizontally
		if Input.is_action_pressed("cannon_move_left"):
			velocity.x -= delta * moveAcceleration
		elif Input.is_action_pressed("cannon_move_right"):
			velocity.x += delta * moveAcceleration
	else:
		# Cannon does not move in auto mode
		pass
		
	# Apply friction to slow down cannon
	if velocity.x > 0:
		velocity.x -= friction * delta
		if velocity.x < 0: velocity.x = 0
	elif velocity.x < 0:
		velocity.x += friction * delta
		if velocity.x > 0: velocity.x = 0
		
	position += velocity # Apply movement based on velocity
	
	# Check if cannon is past left and right bounds
	if position.x < minXPosition:
		position.x = minXPosition
		velocity.x = 0
	elif position.x > maxXPosition:
		position.x = maxXPosition
		velocity.x = 0

func fire_floc():
	removeAmmo(1)
	
	timeSinceFire = 0 # Reset shot cooldown timer
	
	audio.play_shoot_sound() # Play cannon fire sound effect
	
	var shot = flocScene.instantiate() # Create a new shot from the shot scene
	shot.global_position = firePt.global_position # Position the shot at the mouth of the cannon
	# Shot initial velocity direction is the direction from the base of the cannon (rotatePt) to the end (firePt)
	var shotDir = (firePt.global_position - rotatePt.global_position).normalized()
	shot.cannonVelocity = shotSpeed * shotDir # Set the shot's initial velocity to be shotSpeed, in the direction of shotDir
	
	get_parent().add_child(shot) # Add the shot to the scene tree. From here on out, the game physics engine will move it, and its own script can guide its behavior.

func fire_ifas():
	ammoIFAS -= 1
	
	timeSinceFire = 0 # Reset shot cooldown timer
	
	audio.play_ifas_shoot_sound() # Play cannon fire sound effect
	
	var shot = ifasScene.instantiate() # Create a new shot from the shot scene
	shot.global_position = firePt.global_position # Position the shot at the mouth of the cannon
	# Shot initial velocity direction is the direction from the base of the cannon (rotatePt) to the end (firePt)
	var shotDir = (firePt.global_position - rotatePt.global_position).normalized()
	shot.velocity = shotSpeed * shotDir # Set the shot's initial velocity to be shotSpeed, in the direction of shotDir
	
	get_parent().add_child(shot) # Add the shot to the scene tree. From here on out, the game physics engine will move it, and its own script can guide its behavior.

## Fire several flocs all at once, in a spread
func fire_burst(count: int):
	removeAmmo(2)
	audio.play_shoot_sound() # Play cannon fire sound effect
	
	#Failsafe in case of 0
	if burstShotSpreadAngle == 0:
		burstShotSpreadAngle = 1
	# Divides the burst shot angle by the number of flocks shot.
	var anglePerFlock = burstShotSpreadAngle/count
	# Godot doesn't allow for decimal in range, so it has to be done manually.
	var currentAngle = -burstShotSpreadAngle/2

	for i in range(count):
		var shot = flocScene.instantiate() # Create a new shot from the shot scene
		shot.global_position = firePt.global_position # Position the shot at the mouth of the cannon
		# Shot initial velocity direction is the direction from the base of the cannon (rotatePt) to the end (firePt)
		var shotDir = (firePt.global_position - rotatePt.global_position).normalized()
		# Rotates the direction of the shot.
		shotDir = shotDir.rotated(currentAngle)
		shot.cannonVelocity = shotSpeed * shotDir # Set the shot's initial velocity to be shotSpeed, in the direction of shotDir
	
		get_parent().add_child(shot) # Add the shot to the scene tree. From here on out, the game physics engine will move it, and its own script can guide its behavior.

		currentAngle += anglePerFlock # Increment angle
		
func reacquire_target():
	timeSinceTargetCheck = 0
	var target = null
	var minDistance = INF
	for child in get_parent().get_children():
		if child.is_in_group("contaminant"):
			var distToTarget = sqrt(child.global_position.x * global_position.x + child.global_position.y * global_position.y) # Pythagorean theorem
			if distToTarget < minDistance:
				minDistance = distToTarget
				target = child
	
	currentAutoTarget = target # If no targets exist, target remains null

func check_mode_inputs():
	# Change control mode when space is pressed, for testing purposes
	if Input.is_action_just_pressed("cannon_switch_control_mode"):
		if controlMode == ControlMode.PLAYER:
			controlMode = ControlMode.AUTO_SIMPLE
			print("Cannon mode AUTO_SIMPLE")
		elif controlMode == ControlMode.AUTO_SIMPLE:
			controlMode = ControlMode.AUTO_ADVANCED
			print("Cannon mode AUTO_ADVANCED")
		else:
			controlMode = ControlMode.PLAYER
			print("Cannon mode PLAYER")
			
	# Change shot type when F is pressed
	if Input.is_action_just_pressed("cannon_switch_shot_type"):
		if fireMode == FireMode.FLOC:
			fireMode = FireMode.IFAS
			print("Shot type IFAS")
		elif fireMode == FireMode.IFAS:
			fireMode = FireMode.MEMBRANE
			print("Shot type MEMBRANE")
		else:
			fireMode = FireMode.FLOC
			print("Shot type FLOC")

func place_membrane():
	ammoMembrane -= 1
	var membrane = membraneScene.instantiate()
	
	membrane.global_position = get_global_mouse_position()
	membrane.position.y = membraneBaseYCoordinate
	membrane.z_index = -1
	get_parent().add_child(membrane)

func _on_main_on_camera_change(screen: int) -> void:
	if screen == 2:
		canFire = true
	else:
		canFire = false
	return

func ammoInAmmoArea() -> int:
	return $AmmoArea.get_overlapping_bodies().size()

func removeAmmo(n: int) -> void:
	for i in range(n):
		$AmmoArea.get_overlapping_bodies()[0].queue_free()
		await get_tree().create_timer(0.1).timeout

func mouse_in_fire_rect() -> bool:
	# Check if mouse is inside cannon fire rectangle
	var globalPos = get_global_mouse_position()
	if (globalPos.x >= fireRectMin.x and globalPos.y >= fireRectMin.y and globalPos.x <= fireRectMax.x and globalPos.y <= fireRectMax.y):
		return true
	return false
