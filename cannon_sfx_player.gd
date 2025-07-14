extends AudioStreamPlayer2D
class_name CannonSfxPlayer

@export var cannonFireSounds: Array[AudioStream]
var lastPlayedShotSound = -1 # Don't want to play the same sound effect twice in a row

@export var ifasFireSound: AudioStream

func play_shoot_sound() -> void:
	play_shoot_sound_randomize()

func play_shoot_sound_randomize() -> void:
	var numSounds = len(cannonFireSounds)
	# To avoid playing the same sound as last time, instead of just picking a random sound, we pick a number of places to jump ahead in the sound list (minimum 1), then jump that far ahead (looping around to the beginning using modulo if need be)
	var soundChoice = (lastPlayedShotSound + randi_range(1, numSounds-1)) % numSounds
	
	stream = cannonFireSounds[soundChoice]
	play()
	
	lastPlayedShotSound = soundChoice

func play_shoot_sound_pitch_shift():
	# Play the shoot sound with a slight random pitch
	pitch_scale = 1.0 + randf() * 0.2
	play()
	
func play_ifas_shoot_sound() -> void:
	stream = ifasFireSound
	play()
