extends AudioStreamPlayer2D
class_name FlocSfxPlayer

@export var eatSounds: Array[AudioStream]
@export var growSound: AudioStream
var lastPlayedEatSound = -1 # Don't want to play the same sound effect twice in a row

func play_eat_sound() -> void:
	var numSounds = len(eatSounds)
	# To avoid playing the same sound as last time, instead of just picking a random sound, we pick a number of places to jump ahead in the sound list (minimum 1), then jump that far ahead (looping around to the beginning using modulo if need be)
	var soundChoice = (lastPlayedEatSound + randi_range(1, numSounds-1)) % numSounds
	
	stream = eatSounds[soundChoice]
	play()
	
	lastPlayedEatSound = soundChoice

func play_grow_sound() -> void:
	stream = growSound
	play()
