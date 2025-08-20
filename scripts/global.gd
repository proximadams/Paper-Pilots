extends Node

const SAVE_FILE_PATH = 'user://settings.json'

var rng
var settingsData = {
	'musicOn': true,
	'sfxVolume': 50
}

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	_load_settings()

func _load_settings():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return
	var settingsFile := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var jsonString := settingsFile.get_line()
	var json := JSON.new()
	
	var parseResult = json.parse(jsonString)
	if not parseResult == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", jsonString, " at line ", json.get_error_line())
		return
	settingsData = json.data
	pass

func save_settings():
	var settingsFile = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	var jsonString = JSON.stringify(settingsData)

	settingsFile.store_line(jsonString)

func convert_volume_setting_to_db() -> float:
	var result = (4.0 * pow(settingsData.sfxVolume, 0.5)) -40.0
	if result == -40.0:
		result = -80.0
	return result
