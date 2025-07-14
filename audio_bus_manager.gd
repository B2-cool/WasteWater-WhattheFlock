extends Node
# Autoload: no class_name necessary

## An abstraction layer for easy control of audio bus volume levels
## Sits on top of AudioServer and communicates with other scripts

enum AudioBus {BUS_MUSIC, BUS_UI, BUS_SFX, BUS_AMBIENCE}
const busNames = {
	AudioBus.BUS_MUSIC: "Music",
	AudioBus.BUS_UI: "UI",
	AudioBus.BUS_SFX: "Effects",
	AudioBus.BUS_AMBIENCE: "Ambience"
}

var activeBusFades: Array[BusFade] = []

func _process(delta):
	# Every frame, update bus fade effects
	var fades_to_delete = [] # This will store which fades are complete and should be removed from the list of active fades
	for fade in activeBusFades:
		fade.elapsedTime += delta
		
		if fade.elapsedTime >= fade.duration:
			fades_to_delete.append(fade)
			set_bus_volume(fade.bus, fade.targetVolume)
		else:
			var fractionComplete = fade.elapsedTime / fade.duration
			var volume_db = (fractionComplete*fade.targetVolume) + (1-fractionComplete)*fade.startingVolume
			set_bus_volume(fade.bus, volume_db)
			
	for fade in fades_to_delete: activeBusFades.erase(fade)

func mute_bus(bus: AudioBus):
	var busIndex = get_bus_index(bus)
	AudioServer.set_bus_mute(busIndex, true)
	
func unmute_bus(bus: AudioBus):
	var busIndex = get_bus_index(bus)
	AudioServer.set_bus_mute(busIndex, false)
	
func toggle_mute_bus(bus: AudioBus):
	var busIndex = get_bus_index(bus)
	AudioServer.set_bus_mute(busIndex, !AudioServer.is_bus_mute(bus))

func get_bus_volume(bus: AudioBus):
	return db_to_linear(get_bus_volume_db(bus))
	
func set_bus_volume(bus: AudioBus, volume: float):
	set_bus_volume_db(bus, linear_to_db(volume))

func get_bus_volume_db(bus: AudioBus):
	var busIndex = get_bus_index(bus)
	return AudioServer.get_bus_volume_db(busIndex)
	
func set_bus_volume_db(bus: AudioBus, volume_db: float):
	var busIndex = get_bus_index(bus)
	AudioServer.set_bus_volume_db(busIndex, volume_db)
	
func fade_bus_volume(bus: AudioBus, volume_linear: float, duration: float):
	var volume_db = linear_to_db(volume_linear)
	BusFade.new(bus, volume_db, duration)

## Fetches the bus index of a given bus.
## This value is what AudioServer expects, instead of the human-readable name of the bus, or the AudioBus value for it.
func get_bus_index(bus: AudioBus):
	var busName = busNames[bus] # Look up the string name of this bus
	return AudioServer.get_bus_index(busName) # Fetch the index of the bus and return it

# Helper methods to operate on each bus by function name
func mute_sfx(): mute_bus(BUS_SFX)
func mute_music(): mute_bus(BUS_MUSIC)
func mute_ambience(): mute_bus(BUS_AMBIENCE)
func mute_ui(): mute_bus(BUS_UI)

func unmute_sfx(): unmute_bus(BUS_SFX)
func unmute_music(): unmute_bus(BUS_MUSIC)
func unmute_ambience(): unmute_bus(BUS_AMBIENCE)
func unmute_ui(): unmute_bus(BUS_UI)

func toggle_mute_sfx(): toggle_mute_bus(BUS_SFX)
func toggle_mute_music(): toggle_mute_bus(BUS_MUSIC)
func toggle_mute_ambience(): toggle_mute_bus(BUS_AMBIENCE)
func toggle_mute_ui(): toggle_mute_bus(BUS_UI)

# File-scoped bus enums
# This way, other scripts can directly do AudioBusManager.BUS_UI instead of the overly verbose AudioBusManager.AudioBus.BUS_UI
var BUS_UI = AudioBus.BUS_UI
var BUS_MUSIC = AudioBus.BUS_MUSIC
var BUS_AMBIENCE = AudioBus.BUS_AMBIENCE
var BUS_SFX = AudioBus.BUS_SFX

class BusFade:
	## Represents a volume fade transition on a bus.
	
	var duration: float
	var elapsedTime: float
	
	var startingVolume: float
	var targetVolume: float
	
	var bus: AudioBus
	
	func _init(_bus: AudioBus, volume: float, _duration: float):
		self.duration = duration
		self.elapsedTime = 0
		self.bus = bus
		self.startingVolume = AudioBusManager.get_bus_volume(bus)
		self.targetVolume = volume
		
		AudioBusManager.activeBusFades.append(self)
