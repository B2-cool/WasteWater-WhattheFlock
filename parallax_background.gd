extends ParallaxBackground

# Scrolling variables
@export var scroll_speed: float = 100.0  # Adjust scroll speed

# Fading variables
@onready var day_bg = $StillLayer/day
@onready var night_bg = $StillLayer/night
@onready var day_city = $ParallaxLayer/daycity
@onready var night_city = $ParallaxLayer/nightcity
@onready var timer = $Timer

@export var fade_speed := 0.01  # Speed of the fading effect
var transitioning_to_night := true

func _ready():
	if timer:
		timer.timeout.connect(_on_timer_timeout)
		timer.start()
	else:
		print("Timer not found!")

func _process(delta):
	# Move both the background and city sprites horizontally
	scroll_offset.x -= scroll_speed * delta

func _on_timer_timeout():
	# Handle the day-to-night fading effect
	if transitioning_to_night:
		# Fade into night
		night_bg.modulate.a = lerp(night_bg.modulate.a, 1.0, fade_speed)
		day_bg.modulate.a = lerp(day_bg.modulate.a, 0.0, fade_speed)

		night_city.modulate.a = lerp(night_city.modulate.a, 1.0, fade_speed)
		day_city.modulate.a = lerp(day_city.modulate.a, 0.0, fade_speed)

		if night_bg.modulate.a >= 0.99 and night_city.modulate.a >= 0.99:
			transitioning_to_night = false
	else:
		# Fade back into day
		night_bg.modulate.a = lerp(night_bg.modulate.a, 0.0, fade_speed)
		day_bg.modulate.a = lerp(day_bg.modulate.a, 1.0, fade_speed)

		night_city.modulate.a = lerp(night_city.modulate.a, 0.0, fade_speed)
		day_city.modulate.a = lerp(day_city.modulate.a, 1.0, fade_speed)

		if day_bg.modulate.a >= 0.99 and day_city.modulate.a >= 0.99:
			transitioning_to_night = true
