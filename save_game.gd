extends Node

# var Data: Node # might not need this idk
var SAVE_GAME_PATH = "user://game.ini"

# To save data
func save() -> void:
  var config_file := ConfigFile.new()

  config_file.set_value("City", "approval", Global.approval)
  config_file.set_value("City", "name", Global.cityName)
  config_file.set_value("City", "coins", Global.points)

  var error := config_file.save(SAVE_GAME_PATH)
  if error:
	print("An error happened while saving data: ", error)

# To load data
func load() -> void:
  var config_file := ConfigFile.new()
  var error := config_file.load(SAVE_GAME_PATH)

  if error:
	print("An error happened while loading data: ", error)
	return

  Global.health = config_file.get_value("City", "approval", 0.0)
  Global.name = config_file.get_value("City", "name", "City")
  Global.points = config_file.get_value("City", "coins", 0)
