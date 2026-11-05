extends Node

const SAVE_PATH = "user://savegame.cfg"

var player_health = 200
var bgm_volume = 1.0
var sfx_volume = 1.0

func save_game():
	var config = ConfigFile.new()
	config.set_value("PlayerData", "health", player_health)
	config.set_value("Audio", "bgm", bgm_volume)
	config.set_value("Audio", "sfx", sfx_volume)
	config.set_value("GameData", "level_index", GameManager.current_level_index)
	config.save(SAVE_PATH)
	print("GAME SAVED!")

func load_game():
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		player_health = config.get_value("PlayerData", "health", 200)
		bgm_volume = config.get_value("Audio", "bgm", 1.0)
		sfx_volume = config.get_value("Audio", "sfx", 1.0)
		
		# Set volume langsung
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear_to_db(bgm_volume))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume))
		
		GameManager.current_level_index = config.get_value("GameData", "level_index", 0)
		GameManager._load_current_level()
		print("GAME LOADED!")
